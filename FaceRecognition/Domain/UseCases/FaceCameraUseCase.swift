//
//  FaceCameraUseCase.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 02/01/26.
//

import Foundation



final class FaceCameraUseCase {
   
   
    var isMatch: Bool = false
     var matchText: String = ""
    var isMatchModelPreparing = false
    var faceEmbeddingArray = [[Float32]]()
  
    var faceImages: [Data] = []
    var speech = SpeechManager(isGuidance: false)
    private let faceEmbedingRepository: FaceEmbedingRepository
    private let imageStorageManager: ImageStorageManager
   
    init( faceEmbedingRepository: FaceEmbedingRepository, imageStorageManager: ImageStorageManager) {        self.faceEmbedingRepository = faceEmbedingRepository
        self.imageStorageManager = imageStorageManager
        
        }
  
   
    func prepareMatchModel(matchResults: [(String, Int?, Int?,Float, Bool)], completion: @escaping ((Bool)->Void)) {
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
             //   self.delegate?.isMatchChanged(self.isMatch)
                self.faceImages.removeAll()
                self.isMatchModelPreparing = false
                completion(true)
                
            }
            
           
        
    }
    @MainActor func saveFaceImage(_ cgImageArray: [Data], completion: @escaping ((Bool?, String?)) -> Void) {
        DispatchQueue.main.async {
            self.faceImages = cgImageArray
            for imdData in self.faceImages{
                self.faceEmbedingRepository.generateEmbedding(from: imdData) {[weak self] array in
                    if let floatArray = array{
                        if self!.faceEmbeddingArray.count <= 0{
                            self?.faceEmbeddingArray.append(floatArray)
                        }
                        if self!.faceEmbeddingArray.count > 0, self!.faceEmbedingRepository.isTwoEmbedingsForSamePerson(firstEmbeding: self!.faceEmbeddingArray.last!, secondEmbeding: floatArray){
                            self?.faceEmbeddingArray.append(floatArray)
                        }
                       
                        
                        
                    }
                }
            }
            if self.faceEmbeddingArray.count > 0{
               // self.delegate?.stopCapturing()
                
                var matchResults = self.faceEmbedingRepository.checkFaces( faceArray: self.faceEmbeddingArray)
                var match = ""
                
                for  r in matchResults{
                    if r.4 {
                        match = r.0
                    }
                }
                if match == ""{
                    matchResults = self.faceEmbedingRepository.checkFacesInDeap( faceArray: self.faceEmbeddingArray)
                    for  r in matchResults{
                        if r.4 {
                            match = r.0
                        }
                    }
                }
                self.matchText = match
                if self.matchText != ""{
                    if self.faceImages.count > 0, !self.isMatchModelPreparing{
                        self.prepareMatchModel(matchResults: matchResults) { status in
                            completion((true, self.matchText))
                        }
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
                        let text = self.speech.getMentionToAddMoreFaces(for: person)
                        completion((false, text))
                     
                    }
                    else{
                        let text = self.speech.getNoMatchText(for: person)
                        completion((false, text))
                      
                    }
                    print("Similarity-> \(similarity)")
                    if  !self.isMatchModelPreparing{
                        self.faceImages.removeAll()
                        
                    }
                    
                }
                self.faceEmbeddingArray.removeAll()
                
                
            }
            else{
                let text = self.speech.getNoMatchText(for: "person")
                completion((false, text))
          
            }
        }
    }
    /*
    func saveFaceImage(_ cgImageArray: [Data]) {
        
        self.faceImages = cgImageArray
        
            
            faceEmbedingRepository.generateEmbedding(from: cgImage) {[weak self] array in
                if let floatArray = array{
                    DispatchQueue.main.async {
                        if self?.faceEmbeddingArray.count ?? 0 >= 5 {
                            return
                        }
                        if self!.faceEmbeddingArray.count > 0, !self!.faceEmbedingRepository.isTwoEmbedingsForSamePerson(firstEmbeding: self!.faceEmbeddingArray.last!, secondEmbeding: floatArray){
                            print("different not match")
                            return
                        }
                        self?.faceEmbeddingArray.append(floatArray)
                        self?.faceImages.append(cgImage)
                      
                        if self?.faceEmbeddingArray.count == 5{
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
                          
                           
                        }
                        
                    }
                    
                }
            }
        
    }
    */
}


