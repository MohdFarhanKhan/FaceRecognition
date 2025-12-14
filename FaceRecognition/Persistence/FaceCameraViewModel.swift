//
//  FaceCameraViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 22/11/25.
//


import SwiftUI


final class FaceCameraViewModel: NSObject, ObservableObject, CameraDelegate {
    func isCameraRunning(_ isRunning: Bool) {
        DispatchQueue.main.async {
          
            self.isRunning = isRunning
        }
    }
    
   
    @Published var isRunning: Bool = false
    @Published var isMatch: Bool = false
    @Published var matchText: String = ""
   
    var cameraViewModel = CameraViewModel()
    var speech = SpeechManager()
    var faceEmbeddingArray = [[Float32]]()
     var faceViewModel = FaceViewModel()
    
   
    func configure() {
        cameraViewModel.delegate = self
        cameraViewModel.configure()
       
    }
    func convertBoundingBox(_ boundingBox: CGRect,
                            to size: CGSize) -> CGRect {

        let w = boundingBox.width * size.width
        let h = boundingBox.height * size.height
        
        let x = boundingBox.minX * size.width
        let y = (1 - boundingBox.maxY) * size.height // Vision origin is bottom-left

        return CGRect(x: x, y: y, width: w, height: h)
    }
    func getEmbedding(image: CGImage) {
        faceViewModel.getEmbedings(image: image) { array in
            if let floatArray = array{
                self.faceEmbeddingArray.append(floatArray)
                 print("check embeding:\(self.faceEmbeddingArray.count)")
                
            }
        }
    }
    func getVariedImages(cgImage: CGImage){
        if let imgs = self.faceViewModel.faceEmbedGenerator.remover.giveBrightVariedImages(image: cgImage){
            for img in imgs{
               self.getEmbedding(image: img)
            }
        }
    }
    // MARK: Save image
    func saveFaceImage(_ cgImage: CGImage) {
//        autoreleasepool {
//            getVariedImages(cgImage: cgImage)
//            
//            if self.faceEmbeddingArray.count >= 90{
//                self.cameraViewModel.stopCapturing()
//                DispatchQueue.main.async {
//                    self.matchText = self.faceViewModel.checkFaces(faceArray: self.faceEmbeddingArray)
//                    if self.matchText != ""{
//                        self.isMatch = true
//                        self.speech.speak(self.matchText)
//                    }
//                    else{
//                        //  self.isMatch = false
//                    }
//                    self.faceEmbeddingArray.removeAll()
//                    
//                }
//                
//            }
//        }
      
        faceViewModel.getEmbedings(image: cgImage) { array in
            if let floatArray = array{
                  
                self.faceEmbeddingArray.append(floatArray)
               
                if self.faceEmbeddingArray.count >= 10{
                    self.cameraViewModel.stopCapturing()
                    DispatchQueue.main.async {
                           self.matchText = self.faceViewModel.checkFaces(faceArray: self.faceEmbeddingArray)
                        if self.matchText != ""{
                            self.isMatch = true
                            self.speech.speak(self.matchText)
                        }
                        else{
                          //  self.isMatch = false
                        }
                        self.faceEmbeddingArray.removeAll()
                       // self.images.removeAll()
                               }
                   
                }
                
            }
        }
       
       
    }

   
}

