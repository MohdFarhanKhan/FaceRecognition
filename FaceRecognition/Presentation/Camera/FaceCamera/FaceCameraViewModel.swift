//
//  FaceCameraViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 22/11/25.
//


import SwiftUI



final class FaceCameraViewModel: NSObject, ObservableObject, CameraDelegate, FaceCameraDelegate {
   
    
   
    func isCameraRunning(_ isRunning: Bool) {
        
        DispatchQueue.main.async {
            self.isRunning = isRunning
        }
    }
    @Published var selectedLight: LightMode = .none
    @Published var isRunning: Bool = false
    @Published var isMatch: Bool = false
    @Published var matchText: String = ""
    var isMatchModelPreparing = false
    var cameraViewModel = CameraViewModel()
    private let faceCameraUseCase: FaceCameraUseCase
    init( faceCameraUseCase: FaceCameraUseCase) {
        self.faceCameraUseCase = faceCameraUseCase
               }
   
       
   
    func configure() {
        
        faceCameraUseCase.delegate = self
        cameraViewModel.delegate = self
        cameraViewModel.configure()
       
    }
    
    func isMatchChanged(_ isMatch: Bool) {
        DispatchQueue.main.async {
            self.isMatch = isMatch
        }
    }
    
    func matchTextChanged(_ matchText: String) {
        DispatchQueue.main.async {
            self.matchText = matchText
        }
    }
    
    func selectedLightChange(_ lightMode: LightMode) {
        DispatchQueue.main.async {
            self.selectedLight = lightMode
        }
    }
    
    func stopCapturing() {
        DispatchQueue.main.async {
            self.cameraViewModel.stopCapturing()
        }
    }
    

   
   
    // MARK: Save image
    func saveFaceImage(_ cgImage: CGImage) {
        faceCameraUseCase.saveFaceImage(cgImage)
       
        
    }
}

