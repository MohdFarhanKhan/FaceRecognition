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
    
    @Published var selectedLight: LightMode = .none
    @Published var isRunning: Bool = false
    @Published var isMatch: Bool = false
    @Published var matchText: String = ""
    var isMatchModelPreparation = false
    var cameraViewModel = CameraViewModel()
    var speech = SpeechManager(isGuidance: false)
    var faceEmbeddingArray = [[Float32]]()
   // var faceViewModel: FaceViewModel
    // var faceViewModel = FaceViewModel()
    var faceImages: [UIImage] = []
    
    func configure() {
        cameraViewModel.delegate = self
        cameraViewModel.configure()
       
    }
    func nextLightEffect() {
        
        DispatchQueue.main.async {
            switch self.selectedLight{
            case .none:
                self.selectedLight = .soft
            case .soft:
                self.selectedLight = .bright
            case .bright:
                self.selectedLight = .left
            case .left:
                self.selectedLight = .right
            case .right:
                self.selectedLight = .top
            case .top:
                self.selectedLight = .ring
            case .ring:
                self.selectedLight = .none
            }
           
            
        }
       
    }
   
    func getEmbedding(image: CGImage) {
        FaceViewModel.shared.getEmbedings(image: image) {[weak self]  array in
            if let floatArray = array{
                self?.faceEmbeddingArray.append(floatArray)
                 print("check embeding:\(self?.faceEmbeddingArray.count)")
                
            }
        }
        /*
        faceViewModel.getEmbedings(image: image) { array in
            if let floatArray = array{
                self.faceEmbeddingArray.append(floatArray)
                 print("check embeding:\(self.faceEmbeddingArray.count)")
                
            }
        }
         */
    }
   
    func prepareMatchModel(matchResults: [(String, Int?, Int?,Float, Bool)]) {
        isMatchModelPreparation = true
       
           
            DispatchQueue.main.async {
                MatchViewModel.shared.matches.removeAll()
                var index = -1
                for  r in matchResults{
                    index += 1
                    if r.4 {
                        print("Image index: \(index)")
                        let name = r.0
                        let fromImg = self.faceImages[index]
                        
                        if let rIndex = r.1, let cIndex = r.2 {
                            do{
                                let url = try ImageStorageManager.shared.getImageURL(userId: FaceViewModel.shared.faces[rIndex].id, index: FaceViewModel.shared.faces[rIndex].imageURLs[cIndex])
                                MatchViewModel.shared.matches.append(MatchModel(from:fromImg, to: url, name: name, matchPercent: r.3, isMatched: r.4))
                            }
                            catch{
                                MatchViewModel.shared.matches.append(MatchModel(from:fromImg, to: nil, name: name, matchPercent: r.3, isMatched: r.4))
                            }
                           
                        }
                        else{
                            MatchViewModel.shared.matches.append(MatchModel(from:fromImg, to: nil, name: name, matchPercent: r.3, isMatched: r.4))
                        }
                      
                    }
                }
                self.isMatch = true
                self.faceImages.removeAll()
                self.isMatchModelPreparation = false
            }
            
           
        
    }
    // MARK: Save image
    func saveFaceImage(_ cgImage: CGImage) {
       
        FaceViewModel.shared.getEmbedings(image: cgImage) {[weak self] array in
            if let floatArray = array{
                DispatchQueue.main.async {
                    if self?.faceEmbeddingArray.count ?? 0 >= 10 {
                        return
                    }
                self?.faceEmbeddingArray.append(floatArray)
                self?.faceImages.append(UIImage(cgImage: cgImage))
                self?.nextLightEffect()
                if self?.faceEmbeddingArray.count == 10{
                 //   if self.selectedLight == .none{
                        
                       
                            self?.cameraViewModel.stopCapturing()
                            
                    let matchResults = FaceViewModel.shared.checkFaces(faceArray: self?.faceEmbeddingArray ?? [])
                            var match = ""
                            for  r in matchResults{
                                if r.4 {
                                    match = r.0
                                }
                            }
                            self?.matchText = match
                            if self?.matchText != ""{
                                if (self?.faceImages.count)! > 0, !self!.isMatchModelPreparation{
                                    self?.prepareMatchModel(matchResults: matchResults)
                                    self?.speech.speak(self!.matchText)
                                    
                                }
                                
                            }
                            else{
                                var similarity: Float = 0
                                var person = ""
                                for  r in matchResults{
                                    if r.3 >= 0.8 {
                                        similarity = r.3
                                        person = r.0
                                    }
                                }
                                if similarity >= 0.8{
                                    let text = self!.speech.getMentionToAddMoreFaces(for: person)
                                    self!.speech.speak(text)
                                }
                                else{
                                    let text = self!.speech.getNoMatchText(for: person)
                                    self?.speech.speak(text)
                                }
                                
                                if  !self!.isMatchModelPreparation{
                                    self?.faceImages.removeAll()
                                    
                                }
                                
                            }
                            self?.faceEmbeddingArray.removeAll()
                            self?.selectedLight = .none
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                        // Your code here
//                        self?.cameraViewModel.startCapturing()
//                    }
                   
                            //  self.faceImages.removeAll()
                        }
                        
                    }
                    
                }
            }
            
            
       // }
        
    }
}

