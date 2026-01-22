//
//  MoreFacesViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 20/12/25.
//

import Foundation
import AVFoundation
import Vision
import UIKit
import SwiftUI

final class MoreFacesViewModel: NSObject, ObservableObject, CameraDelegate, MoreFacesCameraDelegate {
    func setPhotoSavedCount(_ count: Int) {
        self.savedCount = count
    }
    
    func selectedLightChange(_ lightMode: LightMode) {
        self.selectedLight = lightMode
    }
    
    func setGuidanceSteps(_ guidanceStep: [String]) {
        self.guidanceStep = guidanceStep
    }
    
    func isCameraRunning(_ isRunning: Bool) {
        DispatchQueue.main.async {
          
            self.isRunning = isRunning
        }
    }
    @Published var guidanceStep: [String] = []
    @Published var savedCount: Int = 0
    @Published var isRunning: Bool = false
   
    @Published var selectedLight: LightMode = .none
    var cameraViewModel = CameraViewModel()
   
    
    var userName = ""
    var userId: UUID = UUID()
   
    private let moreFacesUseCase: MoreFacesUseCase
    init(userName: String, userId: UUID,moreFacesUseCase: MoreFacesUseCase) {
        self.userName = userName
        self.userId = userId
        self.moreFacesUseCase = moreFacesUseCase
           }
   
   
   
    func configure() {
        cameraViewModel.delegate = self
        cameraViewModel.configure()
        moreFacesUseCase.delegate = self
        moreFacesUseCase.nextGuidanceStep()
       // self.nextGuidanceStep()
    }

    // MARK: Save image
     func saveFaceImage(_ cgImage: CGImage) {
        guard isRunning else { return }
         moreFacesUseCase.saveFaceImage(cgImage)
        
      
    }
   
    func saveUser( completion: @escaping(Bool) -> Void){
       
        moreFacesUseCase.saveUser(userId: self.userId) { comp in
            completion(comp)
        }
       
       
        
    }
    
}
