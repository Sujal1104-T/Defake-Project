import torch
import torch.nn.functional as F
import numpy as np
from .xception import load_model

class DeepfakeDetector:
    def __init__(self):
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        print(f"Loading Model on {self.device}...")
        self.model = load_model(device=self.device)
        self.model.eval()

    def predict(self, frames):
        """
        Args:
            frames: numpy array (B, C, H, W) normalized 0-1
        Returns:
            dict with confidence and label
        """
        if frames is None or len(frames) == 0:
            return {"confidence": 0.0, "is_deepfake": False, "error": "No faces found"}

        # Convert to Tensor
        frame_tensor = torch.from_numpy(frames).to(self.device)
        
        with torch.no_grad():
            # Get logits
            outputs = self.model(frame_tensor)
            # Apply Softmax
            probs = F.softmax(outputs, dim=1)
            
            # Average probabilities across all frames
            avg_probs = torch.mean(probs, dim=0)
            
            # Class 0: Real, Class 1: Fake (Assumption for binary classifier)
            # Or vice-versa depending on training. Standard: 0=Fake, 1=Real or 0=Real, 1=Fake.
            # Let's assume 1=Deepfake for this demo.
            
            fake_prob = avg_probs[1].item()
            real_prob = avg_probs[0].item()
            
            is_deepfake = fake_prob > 0.5
            confidence = fake_prob if is_deepfake else real_prob
            
            return {
                "is_deepfake": is_deepfake,
                "confidence": round(confidence * 100, 2),
                "fake_prob": fake_prob,
                "real_prob": real_prob
            }
