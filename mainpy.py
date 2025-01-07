import cv2
import mediapipe as mp
import numpy as np
import math

# Initialize MediaPipe Pose module
mp_pose = mp.solutions.pose
pose = mp_pose.Pose()

# Initialize OpenCV VideoCapture
cap = cv2.VideoCapture(0)

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

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Flip the frame for a more intuitive view (optional)
    frame = cv2.flip(frame, 1)
    # Convert to RGB as MediaPipe works with RGB images
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
    # Perform pose detection
    results = pose.process(rgb_frame)
    
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
        cv2.putText(frame, f"Push-ups: {pushup_count}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
        cv2.putText(frame, f"Leg State: {leg_state}", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2, cv2.LINE_AA)
        cv2.putText(frame, f"Push-ups2: {mycount}", (50, 150), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)

        # Render the pose landmarks on the frame (optional for visualization)
        mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

    # Show the live frame with push-up count
    cv2.imshow("Push-up and Leg Detection", frame)

    # Exit condition for pressing 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
