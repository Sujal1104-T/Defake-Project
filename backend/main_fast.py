from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import random
import datetime

app = FastAPI(title="Defake API - Fast Mode", version="2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Defake API (Fast Mode) is running"}

@app.post("/analyze")
async def analyze_video(file: UploadFile = File(...)):
    """Instant analysis with mock results"""
    # Simulate quick analysis
    is_fake = random.random() > 0.5
    confidence = random.uniform(0.65, 0.95)
    
    return JSONResponse(content={
        "is_deepfake": is_fake,
        "confidence": round(confidence, 2),
        "filename": file.filename,
        "anomalies": [
            "Inconsistent texture detected",
            "High confidence manipulation pattern"
        ] if is_fake else []
    })

@app.post("/analyze_frame")
async def analyze_frame(file: UploadFile = File(...)):
    """Instant frame analysis"""
    is_fake = random.random() > 0.7
    confidence = random.uniform(0.60, 0.90)
    
    return JSONResponse(content={
        "is_deepfake": is_fake,
        "confidence": round(confidence, 2)
    })

@app.get("/learn/updates")
async def learn_updates():
    seed_value = datetime.date.today().toordinal()
    random.seed(seed_value)
    
    tips = [
        "Check for unnatural blinking patterns.",
        "Look at the lips for audio-visual desync.",
        "Inspect the background for warping edges.",
        "Watch for overly smooth skin texture.",
    ]
    
    return JSONResponse(content={
        "tip_of_the_day": random.choice(tips),
        "insights": []
    })

if __name__ == "__main__":
    import uvicorn
    import os
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
