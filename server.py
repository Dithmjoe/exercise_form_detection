import cv2
import numpy as np
from flask import Flask, request, Response
import threading
import queue
from flask_cors import CORS  # Import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS

# A queue to store received frames
frame_queue = queue.Queue(maxsize=10)  # Use a queue with a max size to prevent excessive memory usage

# Lock for synchronizing access to the frame queue
frame_lock = threading.Lock()

# Function to process incoming video frames
def process_frames():
    while True:
        frame = frame_queue.get()  # Block until a frame is available in the queue
        if frame is None:
            break  # Stop the thread if no frames are available (or add exit condition)
        
        # Display the frame using OpenCV
        cv2.imshow('Video Stream', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

@app.route('/upload', methods=['POST'])
def upload_frame():
    try:
        # Read the image data sent from the client
        img_data = request.get_data()
        
        if len(img_data) == 0:
            print("Received empty frame data")
            return "No data received", 400
        
        # Convert the byte data to an OpenCV image (numpy array)
        np_img = np.frombuffer(img_data, dtype=np.uint8)
        frame = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

        if frame is None:
            print("Failed to decode the frame")
            return "Failed to decode the frame", 400

        # Add the frame to the queue for processing
        with frame_lock:
            frame_queue.put(frame)
        
        print(f"Received frame of size: {frame.shape}")
        return "Frame received", 200
    except Exception as e:
        print(f"Error: {e}")
        return "Error processing frame", 500

if __name__ == '__main__':
    # Start the frame processing in a separate thread
    threading.Thread(target=process_frames, daemon=True).start()

    # Run the Flask app
    app.run(host='127.0.0.1', port=2000, threaded=True)
