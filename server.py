from flask import Flask, request, send_file
import cv2
import numpy as np
import mediapipe as mp
import os
import io
import traceback

app = Flask(__name__)

# Initialize MediaPipe Pose
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

UPLOAD_FOLDER = "uploads"
PROCESSED_FOLDER = "processed"

# Ensure folders exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)



left_leg_angle=0
right_leg_angle =0
left_angle=0
right_angle=0
# Define the threshold angles for push-ups
ELBOW_ANGLE_UPPER = 160  # Elbow angle when arms are fully extended (push-up top)
ELBOW_ANGLE_LOWER = 80   # Elbow angle when arms are bent (push-up bottom)

# Variable to keep track of push-up state
pushup_count = 0
is_pushing_up = False
track_top=0
track_bottom=0
mycount=0

import cv2
import mediapipe as mp
import numpy as np
import math

# Initialize MediaPipe Pose module
mp_pose = mp.solutions.pose
pose = mp_pose.Pose()

# Initialize OpenCV VideoCapture
cap = cv2.VideoCapture(0)
left_leg_angle=0
right_leg_angle =0
left_angle=0
right_angle=0
# Define the threshold angles for push-ups
ELBOW_ANGLE_UPPER = 160  # Elbow angle when arms are fully extended (push-up top)
ELBOW_ANGLE_LOWER = 80   # Elbow angle when arms are bent (push-up bottom)

# Variable to keep track of push-up state
pushup_count = 0
is_pushing_up = False
track_top=0
track_bottom=0
mycount=0
def calculate_angle(a, b, c):
    """Calculate the angle between three points (a, b, c)"""
    ab = np.array(a) - np.array(b)
    bc = np.array(c) - np.array(b)
    cosine_angle = np.dot(ab, bc) / (np.linalg.norm(ab) * np.linalg.norm(bc))
    angle = np.arccos(np.clip(cosine_angle, -1.0, 1.0))  # Get the angle in radians
    return np.degrees(angle)  # Convert the angle to degrees

def check_pushup(landmarks):
    global right_angle,left_angle,track_top,track_bottom
    """Check if a push-up is happening based on elbow angles"""
    # Get the coordinates for key body points
    left_shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].x, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y]
    left_elbow = [landmarks[mp_pose.PoseLandmark.LEFT_ELBOW].x, landmarks[mp_pose.PoseLandmark.LEFT_ELBOW].y]
    left_wrist = [landmarks[mp_pose.PoseLandmark.LEFT_WRIST].x, landmarks[mp_pose.PoseLandmark.LEFT_WRIST].y]

    right_shoulder = [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].x, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y]
    right_elbow = [landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW].x, landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW].y]
    right_wrist = [landmarks[mp_pose.PoseLandmark.RIGHT_WRIST].x, landmarks[mp_pose.PoseLandmark.RIGHT_WRIST].y]

    # Calculate elbow angles
    left_angle = calculate_angle(left_shoulder, left_elbow, left_wrist)
    right_angle = calculate_angle(right_shoulder, right_elbow, right_wrist)

    # Check if both elbows are bent or extended
    if left_angle > ELBOW_ANGLE_UPPER and right_angle > ELBOW_ANGLE_UPPER:
        track_top=1
        return "top"
    elif left_angle < ELBOW_ANGLE_LOWER and right_angle < ELBOW_ANGLE_LOWER:
        track_bottom=1
        return "bottom"
    return "none"

def check_straight_leg(landmarks):
    global left_leg_angle,right_leg_angle
    """Check if the angle between the shoulder, hip, and knee is straight (180 degrees)"""
    # Get the coordinates for key body points
    left_shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].x, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y]
    left_hip = [landmarks[mp_pose.PoseLandmark.LEFT_HIP].x, landmarks[mp_pose.PoseLandmark.LEFT_HIP].y]
    left_knee = [landmarks[mp_pose.PoseLandmark.LEFT_KNEE].x, landmarks[mp_pose.PoseLandmark.LEFT_KNEE].y]

    right_shoulder = [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].x, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y]
    right_hip = [landmarks[mp_pose.PoseLandmark.RIGHT_HIP].x, landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y]
    right_knee = [landmarks[mp_pose.PoseLandmark.RIGHT_KNEE].x, landmarks[mp_pose.PoseLandmark.RIGHT_KNEE].y]

    # Calculate the angle between shoulder, hip, and knee for both legs
    left_leg_angle = calculate_angle(left_shoulder, left_hip, left_knee)
    right_leg_angle = calculate_angle(right_shoulder, right_hip, right_knee)
    # Check if the angles are close to 180 degrees
    if 170 < left_leg_angle < 190 and 170 < right_leg_angle < 190:
        return "straight"
    return "bent"






@app.route('/upload', methods=['POST'])
def upload_video():
    try:
        global track_top, track_bottom, mycount,pushup_count,is_pushing_up,pushup_state,left_leg_angle,right_leg_angle,right_angle,left_angle
        leg_state='bend'
        mycount
        if 'video' not in request.files:
            return 'No video file provided', 400
        
        # Save uploaded video
        video = request.files['video']
        input_filename = os.path.join(UPLOAD_FOLDER, 'received_video.mp4')
        output_filename = os.path.join(PROCESSED_FOLDER, 'processed_video.mp4')
        video.save(input_filename)
        
        print("✅ Received video, processing started...")

        # Process video with MediaPipe
        cap = cv2.VideoCapture(input_filename)
        if not cap.isOpened():
            return 'Error opening video file', 500

        # Get video properties
        frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))

        if fps == 0:  # Invalid FPS means OpenCV couldn't read the file
            return "Invalid FPS detected, video may be corrupted", 500

        print(f"📌 Video Properties - Width: {frame_width}, Height: {frame_height}, FPS: {fps}")

        # Define the codec and create VideoWriter object
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(output_filename, fourcc, fps, (frame_width, frame_height))

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            #frame = cv2.flip(frame, 0)    
            # Convert the BGR image to RGB
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # Process the frame with MediaPipe Pose
            results = pose.process(frame_rgb)

            # Convert back to BGR for OpenCV
            frame_bgr = cv2.cvtColor(frame_rgb, cv2.COLOR_RGB2BGR)

            # Draw pose landmarks
            

            if results.pose_landmarks:
                # Extract landmarks
                landmarks = results.pose_landmarks.landmark


                # Detect push-up movement
                pushup_state = check_pushup(landmarks)
                # Detect leg angle
                leg_state = check_straight_leg(landmarks)

        # Push-up detection logic
                if pushup_state == "bottom" and not is_pushing_up:
                    pushup_count += 1
                    is_pushing_up = True
                elif pushup_state == "top":
                    is_pushing_up = False
        
                if track_top == 1 and  track_bottom == 1:
                    mycount+=1
                    track_bottom=0
                    track_top=0

        # Display the push-up count and leg state
            
            cv2.putText(frame_rgb, f"Push-ups: {pushup_count}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
            cv2.putText(frame_rgb, f"Leg State: {leg_state}", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2, cv2.LINE_AA)
            cv2.putText(frame_rgb, f"angleleft: {left_leg_angle}", (50, 200), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
            cv2.putText(frame_rgb, f"angleleft: {right_leg_angle}", (50, 250), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
            cv2.putText(frame_rgb, f"elbowleft: {left_angle}", (50, 300), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
            cv2.putText(frame_rgb, f"elbowRight: {right_angle}", (50, 350), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)

        # Render the pose landmarks on the frame (optional for visualization)
           # mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)




            if results.pose_landmarks:
                mp_drawing.draw_landmarks(
                    frame_rgb,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                    mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2)
                )
            # Write processed frame
            out.write(frame_rgb)

        # Release resources
        cap.release()
        out.release()
        cv2.destroyAllWindows()

        print("✅ Processing complete, sending video back...")

        # Send processed video file back to Flutter
        return send_file(
            output_filename,
            mimetype='video/mp4',
            as_attachment=True,
            download_name='returned_video.mp4'
        )
    
    except Exception as e:
        print(f"❌ Error: {e}")
        print(traceback.format_exc())  # Print full error traceback
        return f'Server error: {str(e)}', 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

# Cleanup MediaPipe resources
pose.close()
