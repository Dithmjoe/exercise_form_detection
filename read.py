import inspect

import time
import mediapipe as mp
import cv2
import numpy as np
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

#imports from our own systems
from write import extvals

f = open('./pushup.txt', 'r')
file = f.readlines() #returns a list containg the file contents with each element as a line
num_of_frames = len(file)  #getting how many keyposes there are

count = 0
i = 0

fw = open('./temp.txt', 'w')

while i<=num_of_frames:
    frame_rate = 20
    prev = 0
    cap = cv2.VideoCapture('christo_pushup.mp4')
    with mp_pose.Pose(min_detection_confidence = 0.6, min_tracking_confidence = 0.5) as pose:
        while cap.isOpened():
            
            #switching which state to be compared to
            state = eval(file[i])
            print(count)
            c = 0

            #code to limit the frame rate
            time_elapsed = time.time() - prev
            ret, frame = cap.read()
            if time_elapsed > 1./frame_rate:
                prev = time.time()

#            ret,frame = cap.read()

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

                angles = extvals(landmarks)
                fw.write(str(angles)+'\n')

                #i = 0 # a vairable do not delete

                # while i<num_of_frames:
                #     for angle in angles:
                #         for j in range(len(file[i])):
                #             # if angle-int(file[i][j])<5:
                #             #     i += 1
                #             print(str(int(file[i][j])))

                # print("one pushup done")

                cv2.imshow('Mediapipe feed', image)

                if cv2.waitKey(10) & 0xFF == ord('q'):
                    break
                for j in range(len(state)):
                    if state[j]-angles[j]<18:
                        #print(c)
                        c += 1
                    else:
                        c = 0
                        break
                if c>=7:
    #               print('i:', i)
                    c = 0
                    i += 1
                    if i >= num_of_frames:
                        i = 0
                        count += 1
                    continue
        cap.release()
        cv2.destroyAllWindows()
        break

f.close()