//
//  FaceCameraUseCase.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 02/01/26.
//

import Foundation
import UIKit

protocol FaceCameraDelegate: AnyObject {
  //  func setDelegate(faceCameraDelegate: AnyObject)
  //  func saveFaceImage(_ cgImage: CGImage)
    func isMatchChanged(_ isMatch: Bool)
    func matchTextChanged(_ matchText: String)
    func selectedLightChange(_ lightMode: LightMode)
    func stopCapturing()
}

final class FaceCameraUseCase {
    weak var delegate: FaceCameraDelegate?
    var selectedLight: LightMode = .none
    var isMatch: Bool = false
     var matchText: String = ""
    var isMatchModelPreparing = false
    var faceEmbeddingArray = [[Float32]]()
  
    var faceImages: [UIImage] = []
    var speech = SpeechManager(isGuidance: true)
    private let faceEmbedingRepository: FaceEmbedingRepository
    private let imageStorageManager: ImageStorageManager
   
    init( faceEmbedingRepository: FaceEmbedingRepository, imageStorageManager: ImageStorageManager) {        self.faceEmbedingRepository = faceEmbedingRepository
        self.imageStorageManager = imageStorageManager
        
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
           
           // self.delegate?.selectedLightChange(self.selectedLight)
        }
       
    }
    func prepareMatchModel(matchResults: [(String, Int?, Int?,Float, Bool)]) {
        isMatchModelPreparing = true
       
           
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
                                let url = try self.imageStorageManager.getImageURL(userId: AllStoredPersonsList.shared.faces[rIndex].id, index: AllStoredPersonsList.shared.faces[rIndex].imageURLs[cIndex])
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
                self.delegate?.isMatchChanged(self.isMatch)
                self.faceImages.removeAll()
                self.isMatchModelPreparing = false
            }
            
           
        
    }
    func saveFaceImage(_ cgImage: CGImage) {
        faceEmbedingRepository.generateEmbedding(from: cgImage) {[weak self] array in
            if let floatArray = array{
                DispatchQueue.main.async {
                    if self?.faceEmbeddingArray.count ?? 0 >= 20 {
                        return
                    }
//                    if self!.faceEmbeddingArray.count > 0, !self!.faceEmbedingRepository.checkTwoEmbedingsForSamePerson(firstEmbeding: self!.faceEmbeddingArray.last!, secondEmbeding: floatArray){
//                        print("different not match")
//                        return
//                    }
                self?.faceEmbeddingArray.append(floatArray)
                self?.faceImages.append(UIImage(cgImage: cgImage))
                self?.nextLightEffect()
                if self?.faceEmbeddingArray.count == 20{
                    self?.delegate?.stopCapturing()
                            
                    let matchResults = self?.faceEmbedingRepository.checkFaces( faceArray: self?.faceEmbeddingArray ?? [])
                            var match = ""
                        
                            for  r in matchResults!{
                                if r.4 {
                                    match = r.0
                                }
                            }
                            self?.matchText = match
                            if self?.matchText != ""{
                                if (self?.faceImages.count)! > 0, !self!.isMatchModelPreparing{
                                    self?.prepareMatchModel(matchResults: matchResults!)
                                    self?.speech.speak(self!.matchText)
                                    self?.delegate?.matchTextChanged(self!.matchText)
                                }
                                
                            }
                            else{
                                var similarity: Float = 0
                                var person = ""
                                for  r in matchResults!{
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
                                print("Similarity-> \(similarity)")
                                if  !self!.isMatchModelPreparing{
                                    self?.faceImages.removeAll()
                                    
                                }
                                
                            }
                            self?.faceEmbeddingArray.removeAll()
                            self?.selectedLight = .none
                    self?.delegate?.selectedLightChange(self?.selectedLight ?? .none)
                        }
                        
                    }
                    
                }
            }
            
            
       // }
        
    }
    
}
