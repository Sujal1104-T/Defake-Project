# Contributing to TruthGuard

## Setup Rules

1. **Do not modify Gradle versions** in `android/` unless necessary. The current setup is carefully balanced to support the latest libraries while avoiding "API 36" breaking changes.
2. **NDK Issues**: If you encounter `NDK corrupted` errors, delete the `ndk` folder in your local Android SDK directory and rebuild. Gradle will fetch the pinned version (`26.1.10909125`) automatically.

## API Integration

The app communicates with `https://defake-backend-437i.onrender.com`.
- **Endpoints**:
    - `/analyze`: POST request with video/image file.
    - `/health`: GET request to check server status.

## Formatting
- Run `dart format .` before committing code.
