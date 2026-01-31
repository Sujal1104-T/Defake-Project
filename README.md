# TruthGuard - AI-Powered Deepfake Detection Platform 🛡️

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![License](https://img.shields.io/badge/License-Read--Only-red?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android_%7C_Web-orange?style=for-the-badge)

**TruthGuard** is a cutting-edge deepfake detection system designed to protect users from manipulated media in real-time. Built with a **Flutter** frontend and a robust **Python (FastAPI)** backend, it leverages state-of-the-art Deep Learning models (**XceptionNet**) to analyze videos and live screen content for signs of manipulation.

---

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

## 📂 Project Structure

```text
Defake/
├── android/            # Android native code (Kotlin/Gradle)
├── backend/            # Python FastAPI Backend
│   ├── model/          # AI Model logic & weights
│   ├── main.py         # API Entry point
│   └── requirements.txt
├── lib/                # Flutter Frontend Code
│   ├── providers/      # State Management (Provider)
│   ├── screens/        # UI Pages (Home, Login, Analysis)
│   ├── services/       # API, Auth, & Background Services
│   ├── theme/          # App Design System
│   └── main.dart       # App Entry point
├── web/                # Web entry point & assets
└── assets/             # Static assets (images, icons)
```

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
- **Python**: `3.9+` (3.13 supported)
- **Android Studio**: For APK builds (Android SDK 35, NDK 26.1.10909125)

### 1. Backend Setup
The backend handles the heavy lifting of model inference.

```bash
cd backend

# Create & Activate Virtual Environment
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Mac/Linux:
source .venv/bin/activate

# Install Dependencies
pip install -r requirements.txt

# Run the Server
# Ensure you have the model weights in backend/model/xception-b5690688.pth
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> **Note**: Download the pre-trained Xception weights if not already present: [Link](http://data.lip6.fr/cadene/pretrainedmodels/xception-b5690688.pth) -> Save to `backend/model/xception-b5690688.pth`

### 2. Frontend Setup

```bash
# Install Dependencies
flutter pub get

# Run on Android (Ensure Emulator/Device is connected)
flutter run -d android

# Run on Web
flutter run -d chrome
```

### 3. Firebase Setup (Secrets)
**Important:** You need your own Firebase configuration files.

- **Android**: Place `google-services.json` in `android/app/`.
- **Web**: Create `web/firebase-config.js` with your Firebase SDK keys.

---

## 📱 Build Configurations (Android)

To ensure stability, `android/app/build.gradle.kts` enforces specific library versions:
- **Compile SDK**: 35 (Android 15)
- **Min SDK**: 23 (Android 6.0)
- **Kotlin**: 2.1.0

> **Troubleshooting**: If you see `NDK not found` errors, delete `C:\Users\<user>\AppData\Local\Android\sdk\ndk` and run `flutter build apk` to let it re-download the correct version.

---

## 🤝 Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
This project is licensed under a **Read-Only License**.

Copyright (c) 2026 Sujal Thakur.
The code is provided for educational and review purposes only. **Copying, usage, or deployment is strictly prohibited.**
See `LICENSE` for full terms.
