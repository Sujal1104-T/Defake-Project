# TruthGuard - AI-Powered Deepfake Detection Platform 🛡️

**TruthGuard** is a cutting-edge deepfake detection system designed to protect users from manipulated media in real-time. Built with a **Flutter** frontend and a robust **Python (FastAPI)** backend, it leverages state-of-the-art Deep Learning models (**XceptionNet**) to analyze videos and live screen content for signs of manipulation.

## 🌟 Key Features

### 1. 🔍 Deepfake Analysis
- **Video Upload**: Analyze local video files for deepfake artifacts.
- **Frame-by-Frame Inspection**: The AI examines every frame using the Xception model to detect subtle inconsistencies (blurring, warring edges).
- **Detailed Reports**: Get a confidence score (Real vs. Fake) and a breakdown of the analysis.

### 2. 🛡️ Live Shield (Screen Monitoring)
- **Real-Time Protection**: Monitors your screen activity (ideal for video calls) to warn you if a deepfake face is detected.
- **Background Service**: Runs as a foreground service on Android (using `mediaProjection`) to provide continuous protection even when the app is minimized.
- **Cross-Platform**: Works on Android (via Native Foreground Service) and Web (via Chrome Media Source).

### 3. 📱 User Experience
- **Mobile & Web Support**: A responsive design that works seamlessly on both mobile devices and web browsers.
- **Scan History**: Keep track of all your past analyses with Firebase integration.
- **Notifications**: Stay updated with the latest security tips and detection alerts.
- **Deepfake Academy**: Learn how to spot deepfakes manually with our educational resources.

---

## 🏗️ Technology Stack

### Frontend (Mobile & Web)
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: Provider
- **UI Toolkit**: Material Design with Custom Glassmorphism Theme (`glass_card.dart`, `app_theme.dart`)
- **WebRTC**: For screen stream handling.

### Backend (AI Engine)
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
- **Model**: **XceptionNet** (using `timm` library). Pretrained on ImageNet and fine-tuned for Deepfake Binary Classification.
- **Deployment**: Render / Railway (with CORS support).
- **Database**: Firebase Firestore (for user data and scan history).

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `3.x`
- **Python**: `3.9+`
- **Android Studio**: For APK builds (Android SDK 35, NDK 26.1.10909125)

### 1. Backend Setup
The backend handles the heavy lifting of model inference.
```bash
cd backend
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn main_fast:app --reload --host 0.0.0.0 --port 8000
```

### 2. Frontend Setup
```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on Web
flutter run -d chrome
```


### 3. Firebase Setup (Secrets)
**Important:** This project uses Firebase. You need to provide your own configuration files as they are ignored by git for security.

#### Android
1.  Download `google-services.json` from your Firebase Console.
2.  Place it in `android/app/google-services.json`.

#### Web
1.  Copy the example config:
    ```bash
    cp web/firebase-config.example.js web/firebase-config.js
    ```
2.  Edit `web/firebase-config.js` and add your Firebase keys.

---


## 📱 Build Configurations (Android)

To ensure stability, `android/app/build.gradle.kts` enforces specific library versions:
- **Compile SDK**: 35 (Android 15)
- **Min SDK**: 23 (Android 6.0)
- **Kotlin**: 2.1.0

> **Note**: If you encounter `NDK not found` errors, delete `C:\Users\<user>\AppData\Local\Android\sdk\ndk` and let Flutter re-download the correct version.

---

## 🤝 Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
