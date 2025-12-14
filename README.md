# FaceRecognition iOS App

## 📌 Overview

FaceRecognition is an iOS application built in **Swift** that demonstrates **face registration and face matching** using the device’s front camera. The app allows users to register their face by capturing multiple samples and later verifies a live face against the stored data.

This project is designed as a **learning + showcase project** for iOS development, camera handling, and local persistence, making it suitable for portfolio and resume presentation.

---

## 🚀 Features

* 📷 Live face capture using the front camera
* 🧑‍💻 Face registration by capturing multiple face images
* 💾 Persistent storage using **Core Data**
* 🔍 Face matching against stored images
* ⚡ Real‑time camera preview
* 🧪 Unit Tests & UI Tests included

---

## 🛠 Tech Stack

* **Language:** Swift
* **Platform:** iOS
* **Camera:** AVCaptureSession
* **Persistence:** Core Data
* **Testing:** XCTest, XCUITest
* **Architecture:** MVC (can be extended to MVVM / Clean)

---

## 🧠 High‑Level Architecture

Camera (AVCaptureSession)
→ Face Capture Controller
→ Face Processing Logic
→ Core Data Storage
→ Face Matching Engine
→ Result UI

---

## 📂 Project Structure

```
FaceRecognition/
├── AppDelegate
├── SceneDelegate
├── ViewControllers
│   ├── FaceCaptureViewController.swift
│   ├── FaceMatchViewController.swift
├── CoreData
│   ├── FaceEntity.xcdatamodeld
│   ├── CoreDataManager.swift
├── Utilities
│   ├── CameraManager.swift
│   ├── FaceMatcher.swift
├── FaceRecognitionTests
├── FaceRecognitionUITests
```

---

## ⚙️ Installation & Setup

### Requirements

* macOS with **Xcode 14+**
* iOS 14.0+
* Physical device recommended (camera access)

### Steps

1. Clone the repository

```bash
git clone https://github.com/MohdFarhanKhan/FaceRecognition.git
```

2. Open `FaceRecognition.xcodeproj` in Xcode
3. Select a real iOS device
4. Run the app ▶️

> ⚠️ Camera will not work properly on simulator

---

## 📷 How It Works

### Face Registration

* User captures multiple face images
* Images are stored locally using Core Data
* Each face entry is associated with a unique identifier

### Face Matching

* Live face image is captured
* App compares the captured image against stored samples
* Matching result is displayed to the user

---

## 🧪 Testing

* Unit tests validate Core Data and matching logic
* UI tests validate camera flow and user interactions

Run tests using:

```
Cmd + U
```

---

## 📸 Screenshots / Demo

> (Add screenshots or GIFs here for better visibility)

---

## 📈 Future Improvements

* Integrate **Apple Vision / CoreML** for face embeddings
* Add **liveness detection**
* Display confidence score for recognition
* Migrate UI to **SwiftUI**
* Improve architecture using **MVVM / Clean Architecture**

---

## 📄 License

This project is for educational purposes.

---

## 👨‍💻 Author

**Mohd Farhan Khan**
GitHub: [https://github.com/MohdFarhanKhan](https://github.com/MohdFarhanKhan)
