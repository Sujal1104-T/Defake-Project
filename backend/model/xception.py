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
    
    if weights_path and False: # Disabled for now as we don't have the file
        try:
            state_dict = torch.load(weights_path, map_location=device)
            model.load_state_dict(state_dict)
            print("Loaded fine-tuned weights.")
        except Exception as e:
            print(f"Could not load weights: {e}. Using ImageNet weights.")
    
    model.to(device)
    model.eval()
    return model
