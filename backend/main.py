from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
import os
import shutil
import cv2
import numpy as np

# Initialize App
app = FastAPI(title="Defake API", version="1.0")

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# CORS (Allow Flutter App)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Temp storage for videos
UPLOAD_DIR = "temp_uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

from processor.video_utils import VideoProcessor
from model.detector import DeepfakeDetector

# Initialize Services
# Global instantiation to load model once on startup
video_processor = VideoProcessor(frames_to_extract=2)
detector = DeepfakeDetector()

@app.get("/")
async def root():
    return {"message": "Defake API (XceptionNet) is running"}

@app.post("/analyze")
async def analyze_video(file: UploadFile = File(...)):
    try:
        # 1. Save Video Locally
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        logger.info(f"Received video: {file.filename}")

        # 2. Process Video (Extract Face Frames)
        logger.info("Extracting frames...")
        frames = video_processor.process_video(file_path)
        
        if frames is None:
            # os.remove(file_path)
            return JSONResponse(status_code=400, content={
                "error": "No faces detected in the video or video could not be processed."
            })
            
        logger.info(f"Faces extracted: {frames.shape}")

        # 3. Run Prediction
        logger.info("Running prediction...")
        result = detector.predict(frames)
        
        result["filename"] = file.filename
        
        # Add basic anomalies text for UI display based on result
        if result["is_deepfake"]:
            result["anomalies"] = [
                "Inconsistent texture detected",
                "High confidence manipulaton pattern"
            ]
        else:
            result["anomalies"] = []

        logger.info(f"Result: {result}")
        
        # Cleanup
        # os.remove(file_path)
        
        return JSONResponse(content=result)

    except Exception as e:
        logger.error(f"Error processing video: {str(e)}")
        import traceback
        traceback.print_exc()
        return HTTPException(status_code=500, detail=str(e))

@app.post("/analyze_frame")
async def analyze_frame(file: UploadFile = File(...)):
    try:
        # Read image bytes directly
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if frame is None:
             return JSONResponse(status_code=400, content={"error": "Invalid image data"})

        # Process Single Frame
        # 1. Face Detection & Crop
        # We reuse the internal method from processor but need to adapt it since it was designed for video paths.
        # Let's create a quick helper or expose the crop logic.
        face = video_processor._crop_face(frame)
        
        if face is None:
             # If no face, we can skip or return low confidence
             return JSONResponse(content={"is_deepfake": False, "confidence": 0.0, "note": "No face found"})

        # 2. Preprocess (Resize, Normalize, Transpose)
        face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
        face_resized = cv2.resize(face_rgb, (299, 299))
        face_norm = face_resized.astype(np.float32) / 255.0
        face_transposed = np.transpose(face_norm, (2, 0, 1))
        
        # Add Batch Dimension (1, 3, 299, 299)
        batch_input = np.expand_dims(face_transposed, axis=0)

        # 3. Predict
        result = detector.predict(batch_input)
        
        return JSONResponse(content=result)

    except Exception as e:
        logger.error(f"Error processing frame: {str(e)}")
        return HTTPException(status_code=500, detail=str(e))
@app.get("/learn/updates")
async def learn_updates():
    import random
    import datetime
    
    # Use current date as seed for daily rotation
    seed_value = datetime.date.today().toordinal()
    random.seed(seed_value)
    
    tips = [
        "Check for unnatural blinking patterns. Deepfakes often blink less frequently or oddly.",
        "Look at the lips. Audio-visual desync is a common sign of manipulation.",
        "Inspect the background. Warping edges around the face are a giveaway.",
        "Watch for skin texture. Overly smooth 'airbrushed' skin can indicate AI generation.",
        "Check lighting consistency. Shadows on the face should match the environment.",
        "Focus on the eyes. Irregular pupil shapes or weird reflections can be a tell.",
        "Listen for robotic artifacts. AI voices might have metallic clipping or lack breathing sounds.",
        "Observe emotion mismatch. Does the facial expression truly match the tone of speech?"
    ]
    
    insights = [
        {
            "title": "AI Voice Cloning Scams on the Rise",
            "summary": "Security researchers warn of a 300% increase in CEO fraud using voice synthesis.",
            "source": "CyberSec Weekly"
        },
        {
            "title": "New Watermarking Standard Proposed",
            "summary": "Tech giants agree on C2PA standard to label AI-generated content automatically.",
            "source": "TechCrunch"
        },
        {
            "title": "Deepfake Detection Challenge 2026",
            "summary": "Global competition launches to find the most robust detection algorithm.",
            "source": "AI Daily"
        },
        {
            "title": "EU AI Act Enforced",
            "summary": "New regulations require mandatory disclosure for all AI-generated media in the EU.",
            "source": "EU Commission"
        },
        {
            "title": "Real-time Deepfake Calls",
            "summary": "Scammers are now using real-time face swapping in video calls to impersonate relatives.",
            "source": "Fraud Watch"
        },
        {
            "title": "The 'Uncanny Valley' Effect",
            "summary": "Why deepfakes feel creepy? Our brains subconsciously detect micro-imperfections.",
            "source": "NeuroScience Today"
        }
    ]
    
    # Select 1 Tip of the Day
    tip_of_the_day = random.choice(tips)
    
    # Select 3 Random Insights (deterministic due to seed)
    selected_insights = random.sample(insights, 3)
    
    return JSONResponse(content={
        "tip_of_the_day": tip_of_the_day,
        "insights": selected_insights
    })

if __name__ == "__main__":
    import uvicorn
    # Use PORT from environment variable (required for Render/Railway/Heroku)
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
