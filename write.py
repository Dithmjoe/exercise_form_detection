import inspect

import mediapipe as mp
import cv2
import numpy as np
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

#Placeholder code clean it up. also if trying to render and the image not appearing properly colored
#try checking if my dumbass converted it back to BGR
image_start = cv2.imread('.\pushups\human_Pushup_start.jpg')
image_start = cv2.cvtColor(image_start, cv2.COLOR_BGR2RGB)
image_mid = cv2.imread('.\pushups\human_Pushup_mid.jpg')
image_mid = cv2.cvtColor(image_mid, cv2.COLOR_BGR2RGB)
image_stop = cv2.imread('.\pushups\human_Pushup_start.jpg')
image_stop = cv2.cvtColor(image_stop, cv2.COLOR_BGR2RGB)

#initialize this to the number of frames uploaded
# num_of_frames= 3 found a better way which is to use readlines after storing

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

#output list is of angles of the form: [left_elbow, right_elbow, left_shoulder, right_shoulder, left_hip, right_hip, left_knee, right_knee]
def extvals(landmarks) -> list[int]: #This will extract the values and fetch the angles into a list which will be returned
        returnee = []
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
        returnee.append(calc_angle(left_shoulder, left_elbow, left_wrist))
        returnee.append(calc_angle(right_shoulder, right_elbow, right_wrist))
        returnee.append(calc_angle(left_elbow, left_shoulder, left_hip))
        returnee.append(calc_angle(right_elbow, right_shoulder, right_hip))
        returnee.append(calc_angle(left_shoulder, left_hip, left_knee))
        returnee.append(calc_angle(right_shoulder, right_hip, right_knee))
        returnee.append(calc_angle(left_hip, left_knee, left_ankle))
        returnee.append(calc_angle(right_hip, right_knee, right_ankle))

        return returnee


with mp_pose.Pose(min_detection_confidence = 0.6, min_tracking_confidence = 0.5) as pose:

    #setting the images to non writeable before processing them
    # image_start.flags.writeable = False
    # image_mid.flags.writeable = False
    # image_stop.flags.writeable = False
    results_start = pose.process(image_start)
    results_mid = pose.process(image_mid)
    results_stop = pose.process(image_stop)

    #Pretty sure I don't need to do this but still
    # image_start.flags.writeable = True
    # image_mid.flags.writeable = True
    # image_stop.flags.writeable = True

    landmarks_start = results_start.pose_landmarks.landmark
    landmarks_mid = results_mid.pose_landmarks.landmark
    landmarks_stop = results_stop.pose_landmarks.landmark

    #extracting and storing the values into a list
    angle_start = extvals(landmarks_start)
    angle_mid = extvals(landmarks_mid)
    angle_stop = extvals(landmarks_stop)

    #writing to file also bad code
    f = open("pushup.txt", "w")
    # f.write(str(num_of_frames))
    # f.write("\n")
#    f.write("\nangle start\n")
    f.write(str(angle_start))
    f.write("\n")
#    f.write("\nangle mid\n")
    f.write(str(angle_mid))
    f.write("\n")
#    f.write("\nangle stop\n")
    f.write(str(angle_stop))
    f.write("\n")
    f.close()