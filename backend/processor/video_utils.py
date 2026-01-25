import cv2
import numpy as np
import os
from PIL import Image

class VideoProcessor:
    def __init__(self, target_size=(299, 299), frames_to_extract=15):
        self.target_size = target_size
        self.frames_to_extract = frames_to_extract
        # Load Face Detector (Haar Cascade is faster for CPU than MTCNN)
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

    def process_video(self, video_path):
        """
        Extracts frames from video, detects faces, crops them, and prepares for model.
        Returns: numpy array of shape (N, 3, 299, 299)
        """
        cap = cv2.VideoCapture(video_path)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        if total_frames <= 0:
            return None
        
        # Calculate interval to get evenly spaced frames
        interval = max(1, total_frames // self.frames_to_extract)
        
        processed_frames = []
        count = 0
        
        while cap.isOpened() and len(processed_frames) < self.frames_to_extract:
            ret, frame = cap.read()
            if not ret:
                break
                
            if count % interval == 0:
                face = self._crop_face(frame)
                if face is not None:
                    # Convert BGR to RGB
                    face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
                    # Resize
                    face_resized = cv2.resize(face_rgb, self.target_size)
                    # Normalize (0-1)
                    face_norm = face_resized.astype(np.float32) / 255.0
                    # Transpose to (C, H, W) for PyTorch
                    face_transposed = np.transpose(face_norm, (2, 0, 1))
                    processed_frames.append(face_transposed)
            
            count += 1
            
        cap.release()
        
        if len(processed_frames) == 0:
            return None
            
        return np.array(processed_frames)

    def _crop_face(self, frame):
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(gray, 1.3, 5)
        
        # If no face, return center crop or full frame (fallback)
        if len(faces) == 0:
            # Simple center crop fallback if face not found
            h, w, _ = frame.shape
            min_dim = min(h, w)
            start_x = (w - min_dim) // 2
            start_y = (h - min_dim) // 2
            return frame[start_y:start_y+min_dim, start_x:start_x+min_dim]
        
        # Take the largest face
        # (x, y, w, h)
        faces = sorted(faces, key=lambda x: x[2] * x[3], reverse=True)
        x, y, w, h = faces[0]
        
        # Add some margin
        margin = int(w * 0.2)
        x = max(0, x - margin)
        y = max(0, y - margin)
        w = min(frame.shape[1] - x, w + 2 * margin)
        h = min(frame.shape[0] - y, h + 2 * margin)
        
        return frame[y:y+h, x:x+w]
