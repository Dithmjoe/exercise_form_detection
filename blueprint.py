import mediapipe as mp
import cv2
import numpy as np
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

#trignometry magic. don't ask me how I picked it up from a ss from a video in yt from a channel named nicholas renotte
def calc_angle(a, b, c):
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)

    radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
    degrees = np.abs(radians*180.0/np.pi)

    if degrees>180.0:
        degrees = 360-degrees
    return degrees



cap = cv2.VideoCapture(0)
with mp_pose.Pose(min_detection_confidence = 0.6, min_tracking_confidence = 0.5) as pose:
    while cap.isOpened():
        ret,frame = cap.read()

        #Recoloring the image to rgb cause cv2 gives images in bgr and mediapipe expects in rgb
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False

        #making prediction/processing the frames
        results = pose.process(image)

        #Recoloring the image back to bgr to pass it to cv2
        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

        #rENDERING THE detection aka drawing the dots and lines on the image
        mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS,
                                    mp_drawing.DrawingSpec(color = (255, 255, 255), thickness = 2, circle_radius = 2),  #recoloring the dots from the default colors
                                    mp_drawing.DrawingSpec(color = (255, 255, 255), thickness = 3, circle_radius = 1),  #recoloring the connections from the default colors
                                  )

        landmarks = results.pose_landmarks.landmark

        #extracting values into variables
        left_shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y, landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].visibility]
        right_shoulder = [landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y, landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].visibility]
        left_elbow = [landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].x, landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].y, landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].visibility]        
        right_elbow = [landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].y, landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].visibility]
        left_wrist = [landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].x, landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].y, landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].visibility]
        right_wrist = [landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].y, landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].visibility]
        left_hip = [landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].x, landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].y, landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].visibility]
        right_hip = [landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].y, landmarks[mp_pose.PoseLandmark.RIGHT_HIP.value].visibility]
        left_knee = [landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].x, landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y, landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].visibility]
        right_knee = [landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].y, landmarks[mp_pose.PoseLandmark.RIGHT_KNEE.value].visibility]
        left_ankle = [landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].x, landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].y, landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].visibility]
        right_ankle = [landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE.value].x, landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE.value].y, landmarks[mp_pose.PoseLandmark.RIGHT_ANKLE.value].visibility]

        #calculating angles
        left_elbow_angle = calc_angle(left_shoulder, left_elbow, left_wrist)
        right_elbow_angle = calc_angle(right_shoulder, right_elbow, right_wrist)
        left_shoulder_angle = calc_angle(left_elbow, left_shoulder, left_hip)
        right_shoulder_angle = calc_angle(right_elbow, right_shoulder, right_hip)
        left_hip_angle = calc_angle(left_shoulder, left_hip, left_knee)
        right_hip_angle = calc_angle(right_shoulder, right_hip, right_knee)
        left_knee_angle = calc_angle(left_hip, left_knee, left_ankle)
        right_knee_angle = calc_angle(right_hip, right_knee, right_ankle)

        cv2.imshow('Mediapipe feed', image)

        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()