from flask import Flask, request, send_file
import cv2
import numpy as np
import mediapipe as mp
import os
import io
import traceback
from write import extvals

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

f = open('./pushup.txt', 'r')
file = f.readlines() #returns a list containg the file contents with each element as a line
num_of_frames = len(file)  #getting how many keyposes there are



def calculate_angle(a, b, c):
    """Calculate the angle between three points (a, b, c)"""
    ab = np.array(a) - np.array(b)
    bc = np.array(c) - np.array(b)
    cosine_angle = np.dot(ab, bc) / (np.linalg.norm(ab) * np.linalg.norm(bc))
    angle = np.arccos(np.clip(cosine_angle, -1.0, 1.0))  # Get the angle in radians
    return np.degrees(angle)  # Convert the angle to degrees

def predict_shoulder(elbow, wrist,w,h):
    """Predict shoulder position by extending the elbow-wrist vector."""
    dx = elbow.x - wrist.x
    dy = elbow.y - wrist.y

    predicted_shoulder_x = elbow.x + dx  # Extend in opposite direction
    predicted_shoulder_y = elbow.y + dy  # Extend in opposite direction
        
    # Ensure coordinates are within valid range
    predicted_shoulder_x = min(max(predicted_shoulder_x, 0), 1)
    predicted_shoulder_y = min(max(predicted_shoulder_y, 0), 1)

    return int(predicted_shoulder_x * w), int(predicted_shoulder_y * h)

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
        if 'video' not in request.files:
            return 'No video file provided', 400
        
        # Save uploaded video
        video = request.files['video']
        input_filename = os.path.join(UPLOAD_FOLDER, 'received_video.mp4')
        output_filename = os.path.join(PROCESSED_FOLDER, 'processed_video.mp4')
        video.save(input_filename)
        
        print("✅ Received video, processing started...")

        count=0
        i=0

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
            
            state = eval(file[i])
            c = 0       


            h, w, _ = frame.shape  
            # Convert the BGR image to RGB
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # Process the frame with MediaPipe Pose
            results = pose.process(frame_rgb)

            # Convert back to BGR for OpenCV
            frame_bgr = cv2.cvtColor(frame_rgb, cv2.COLOR_RGB2BGR)

            # Draw pose landmarks
            if results.pose_landmarks:
                mp_drawing.draw_landmarks(
                    frame_bgr,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(255, 255, 0), thickness=1, circle_radius=1),
                    mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=1)
                )
            if results.pose_landmarks:
                landmarks = results.pose_landmarks.landmark
                left_shoulder = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER]
                left_ankle = landmarks[mp_pose.PoseLandmark.LEFT_ANKLE]
                right_shoulder = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER]
                right_ankle = landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE]

                # Convert normalized coordinates to pixel values
                left_shoulder_point = (int(left_shoulder.x * w), int(left_shoulder.y * h))
                left_ankle_point = (int(left_ankle.x * w), int(left_ankle.y * h))
                right_shoulder_point = (int(right_shoulder.x * w), int(right_shoulder.y * h))
                right_ankle_point = (int(right_ankle.x * w), int(right_ankle.y * h))
                left_elbow = landmarks[mp_pose.PoseLandmark.LEFT_ELBOW]
                right_elbow = landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW]
                # Convert normalized coordinates to pixel values
                left_elbow_point = (int(left_elbow.x * w), int(left_elbow.y * h))
                right_elbow_point = (int(right_elbow.x * w), int(right_elbow.y * h))
                # Draw green line from elbow to ankle
                cv2.line(frame_bgr, left_elbow_point, left_ankle_point, (0, 255, 255), 1)
                cv2.line(frame_bgr, right_elbow_point, right_ankle_point, (0, 255, 255), 1)
                # Draw green line from shoulder to ankle
                cv2.line(frame_bgr, left_shoulder_point, left_ankle_point, (0, 255, 0), 1)
                cv2.line(frame_bgr, right_shoulder_point, right_ankle_point, (0, 255, 0), 1)

                left_wrist = landmarks[mp_pose.PoseLandmark.LEFT_WRIST]
                right_wrist = landmarks[mp_pose.PoseLandmark.RIGHT_WRIST]
                predicted_left_shoulder = predict_shoulder(left_elbow, left_wrist,w,h)
                predicted_right_shoulder = predict_shoulder(right_elbow, right_wrist,w,h)
                cv2.line(frame_bgr, predicted_left_shoulder, left_ankle_point, (0, 255, 255), 1) 
                cv2.line(frame_bgr, predicted_right_shoulder, right_ankle_point, (0, 255, 255), 1)
                cv2.line(frame_bgr, predicted_left_shoulder, left_elbow_point, (0, 255, 255), 1) 
                cv2.line(frame_bgr, predicted_right_shoulder, right_elbow_point, (0, 255, 255), 1)


                angles = extvals(landmarks)

                for j in range(len(state)):
                    if abs(state[j]-angles[j])<22:
                        #print(c)
                        c += 1
                    else:
                        c = 0
                        break
                if c>=7:
                    #print('i:', i)
                    c = 0
                    i += 1
                    if i >= num_of_frames:
                        i = 0
                        count += 1
                    continue

                leg_state = check_straight_leg(landmarks)

                cv2.putText(frame_bgr, f"Body State: {leg_state}", (50, 400), cv2.FONT_HERSHEY_DUPLEX, 1, (255, 0, 0), 1, cv2.LINE_AA)
                cv2.putText(frame_bgr, f"Push-up Count: {count}", (50, 350), cv2.FONT_HERSHEY_DUPLEX, 1, (255, 0, 0), 1, cv2.LINE_AA)





            # Write processed frame
            out.write(frame_bgr)

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