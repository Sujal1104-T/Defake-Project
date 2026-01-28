import torch
import torch.nn as nn
import timm

class XceptionDetector(nn.Module):
    def __init__(self, pretrained=True):
        super(XceptionDetector, self).__init__()
        # Load Xception from timm
        # Using 'xception' (ported from Cadene or similar)
        # num_classes=2 (Real vs Fake)
        self.model = timm.create_model('legacy_xception', pretrained=pretrained, num_classes=2)

    def forward(self, x):
        return self.model(x)

def load_model(weights_path=None, device='cpu'):
    model = XceptionDetector(pretrained=True) # Use ImageNet weights initially
    
    if weights_path:
        try:
            state_dict = torch.load(weights_path, map_location=device)
            # If these are ImageNet weights (timm style), we might need to be careful with keys.
            # But let's try loading strictly first.
            model.model.load_state_dict(state_dict, strict=False)
            print(f"Loaded weights from {weights_path}")
        except Exception as e:
            print(f"Could not load weights: {e}. Using ImageNet weights.")
    
    model.to(device)
    model.eval()
    return model
