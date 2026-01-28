//
//  FaceCameraViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 22/11/25.
//


import SwiftUI
import MessageUI


final class FaceCameraViewModel: NSObject, ObservableObject, @preconcurrency CameraDelegate {
   
    
   
    func isCameraRunning(_ isRunning: Bool) {
        
        DispatchQueue.main.async {
            self.isRunning = isRunning
        }
    }
    @Published var selectedLight: LightMode = .none
    @Published var isRunning: Bool = false
    @Published var isMatch: Bool = false
    @Published var matchText: String = ""
    var imageDataArray = [Data]()
    var isMatchModelPreparing = false
    var cameraViewModel = CameraViewModel()
    var speech = SpeechManager(isGuidance: false)
    private let faceCameraUseCase: FaceCameraUseCase
    init( faceCameraUseCase: FaceCameraUseCase) {
        self.faceCameraUseCase = faceCameraUseCase
               }
   
       
   
    func configure() {
        
        
        cameraViewModel.delegate = self
        cameraViewModel.configure()
       

        // Example usage:
        /*
        if let blogPosts = posts {
            print("Loaded \(blogPosts.count) blog posts.")
            for post in blogPosts {
                if let image = self.convertBase64ToImage(base64String: post.images[0]){
                    print(image)
                }
            }
        }
         */
        /*
        let posts = loadJson(filename: "FaceRecognitionJSONTest")

        // Example usage:
        if let blogPosts = posts {
            print("Loaded \(blogPosts.count) blog posts.")
            for post in blogPosts {
                print(post.name)
            }
        }
         */
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
    @MainActor func saveFaceImage(_ cgImage: CGImage) {
        if imageDataArray.count >= 5{
            return
        }
        if let jpegData = cgImage.jpegData(compressionQuality: 0.8) {
            if imageDataArray.count < 5{
                self.imageDataArray.append(jpegData)
            }
            if imageDataArray.count == 5{
                self.stopCapturing()
                faceCameraUseCase.saveFaceImage(imageDataArray) { [self] status in
                    imageDataArray.removeAll()
                    speech.speak(status.1!)
                    if status.0 == true{
                        self.isMatch = true
                        self.matchText = status.1!
                    }
//                    self.cameraViewModel.startCapturing()
                }
//                faceCameraUseCase.saveFaceImage(imageDataArray, completion: ((Bool?, String?)) -> Void)
            }
            
        }
        
    }
    func imageToBase64(image: UIImage) -> String? {
        // Convert UIImage to Data (JPEG representation)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            // Encode Data to a Base64 string
            return jpegData.base64EncodedString()
        }
        return nil
    }
    @MainActor func getArray()->[IdImages]{
        var idImageArray = [IdImages]()
        for p in AllStoredPersonsList.shared.faces{
            let imgArray = ImageStorageManager.shared.loadImages(userId: p.id).map { e in
                return self.imageToBase64(image: e)!
            }
           
            idImageArray.append(IdImages(id: p.id, images: imgArray))
        }
        return idImageArray
    }
    @MainActor func mailJSON(){
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted    // ← makes it beautiful
             encoder.outputFormatting = [.prettyPrinted, .sortedKeys]  // even nicer
            let array = self.getArray()
            let jsonData = try encoder.encode(array)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
               
            }
        } catch {
            print("Encoding failed: \(error)")
        }
    }
}

