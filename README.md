# Defake - Deepfake Detection App

## Getting Started

### Prerequisites

1.  **Flutter SDK**: Ensure Flutter is installed and in your PATH.
2.  **Visual Studio (Windows)**:
    *   **Crucial Step**: Installation of "Visual Studio" (the IDE) is not enough.
    *   You **MUST** install the **"Desktop development with C++"** workload via the Visual Studio Installer.
    *   Flutter for Windows relies on the MSVC compiler and CMake, which are part of this workload.

### Running the App

#### Option 1: Web (Recommended for Quick Testing)
You can run the app immediately in your browser (Google Chrome or Edge) without additional installations.

```bash
flutter run -d chrome
```

#### Option 2: Windows
Once you have installed the "Desktop development with C++" workload:

```bash
flutter run -d windows
```

#### Option 3: Android
Launch your Android Emulator via Android Studio, then run:

```bash
flutter run
```

## Troubleshooting

### "Visual Studio not installed" Error
If specific components are missing, `flutter doctor` will report VS as not installed.
1.  Open **Visual Studio Installer**.
2.  Click **Modify**.
3.  Select **Desktop development with C++**.
4.  Install/Update.
