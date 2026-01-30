# 📱 FaceRecognition – iOS (SwiftUI + Vision)

FaceRecognition is a **production‑oriented iOS application** built using **Swift, SwiftUI, AVFoundation, and Apple Vision** that demonstrates real‑time face detection, face capture, and basic face matching.  
The project is structured with **clean architecture principles**, focusing on separation of concerns, testability, and scalability.

> ⚠️ This project is intended for **educational and demo purposes**. It does not implement biometric‑grade face recognition security.

---

## ✨ Features

- 📷 **Real‑time camera preview** using `AVCaptureSession`
- 🙂 **Face detection** using Apple Vision (`VNDetectFaceRectanglesRequest`)
- 👥 **Capture and store multiple faces**
- 🔍 **Basic face matching flow** (demo‑level logic)
- 💾 **Local persistence** using Core Data
- 🧠 **MVVM + UseCase architecture**
- 🎨 **SwiftUI‑first UI design**
- 🔄 Camera lifecycle & permission handling

---

## 🏗 Architecture Overview

The project follows a **layered, clean architecture** approach:

```
Presentation (SwiftUI)
 ├─ Views
 ├─ ViewModels

Domain
 ├─ Models
 ├─ UseCases

Infrastructure
 ├─ Camera / AVFoundation
 ├─ Vision (Face Detection)
 ├─ Persistence (Core Data)
 ├─ Utilities
```

### Why this architecture?
- Clear separation of responsibilities
- Easier testing & mocking
- Scales well as features grow
- Suitable for production‑grade apps

---

## 🧩 Key Modules

### 📸 Camera Module
- Handles camera permissions
- Manages `AVCaptureSession`
- Provides preview layer to SwiftUI
- Sends frames for Vision processing

### 👁 Vision / Face Detection
- Uses Apple Vision framework
- Detects faces from video frames
- Returns bounding boxes & observations

### 🧠 Domain Layer
- `UseCase` driven business logic
- Models kept framework‑agnostic

### 💾 Persistence
- Stores captured faces locally
- Core Data based implementation

---

## 🛠 Tech Stack

| Technology | Usage |
|----------|------|
| Swift 5+ | Core language |
| SwiftUI | UI Layer |
| AVFoundation | Camera handling |
| Vision | Face detection |
| Core Data | Local storage |
| MVVM | Presentation architecture |

---

## 🚀 Getting Started

### Requirements
- macOS Sonoma / Ventura
- Xcode 15+
- iOS 16+
- Physical iPhone device (camera required)

### Setup Steps

1. Clone the repository
```bash
git clone https://github.com/your-username/FaceRecognition.git
```

2. Open the project
```bash
open FaceRecognition.xcodeproj
```

3. Select a **real iPhone device** (camera not supported on simulator)

4. Run the app ▶️

---

## 🔐 Permissions

The app requires camera access. Make sure this key exists in `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for face detection.</string>
```

---

## 🧪 Testing

The project includes **unit and UI tests** aligned with production-grade Swift practices.

### ✅ Unit Tests
- **Domain Layer**
  - `FaceCameraUseCaseTests`
- **Presentation Layer**
  - `FaceCameraViewModelTests`

### 🧪 Mocks & Test Utilities
- `FaceEmbeddingGeneratorMock`
- `PersonRepositoryMock`

Protocols and dependency injection are used to enable **isolated, deterministic tests** without relying on camera or Vision hardware.

### 📱 UI Tests
- `FaceRecognitionUITests`
- `FaceRecognitionUITestsLaunchTests`

These tests validate app launch stability and basic UI flows.

---


## ⚠️ Limitations

- Uses **Vision face detection**, not biometric face recognition
- No Face ID / Secure Enclave usage
- Matching logic is **demo‑level** only
- Not suitable for identity verification or authentication

---

## 🔮 Future Improvements

- Swift Concurrency (`async/await`) throughout
- Proper face embeddings & similarity scoring
- Vision → CoreML model integration
- Better camera state management
- Unit & UI test coverage
- SwiftLint integration

---

## 📚 Learning Outcomes

This project is useful if you want to learn:
- Camera handling in iOS
- Vision framework basics
- SwiftUI + AVFoundation integration
- Clean architecture in Swift apps
- Real‑time frame processing

---

## 📄 License

This project is provided for **learning and demonstration purposes only**.
You are free to explore, modify, and extend it.

---

## 🙌 Author

**Mohd Khan**  
iOS Developer | Swift | SwiftUI

---

⭐ If this project helped you learn something, consider giving it a star!

