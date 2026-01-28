//
//  FaceCaptureUseCase.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 02/01/26.
//

import Foundation
import UIKit

protocol FaceCaptureCameraDelegate: AnyObject {
    func setUserNameAlert(_ userNameAlert: Bool)
    func setPhotoSavedCount(_ count: Int)
    
    func stopCapturing()
    func setGuidanceSteps(_ guidanceStep: [String])
}

final class FaceCaptureCameraUseCase {
    weak var delegate: FaceCaptureCameraDelegate?
    var guidanceStep: [String] = []
     var savedCount: Int = 0
    
     
    var speech = SpeechManager(isGuidance: true)
    private let faceEmbedingRepository: FaceEmbedingRepository
    private let imageStorageManager: ImageStorageManager
    var embedingArray = [[Float32]]()
    var photoArray = [UIImage]()
    private var guidanceSteps = [
        ["Look straight","faceid"],
       [ "Look left","arrow.turn.left.up"],
        ["Look right","arrow.turn.right.up"],
        ["Look up","arrow.up.circle"],
        ["Look down","arrow.down.circle"],
        ["Smile","face.smiling"],
        ["Neutral face","face.neutral"],
        ["Open mouth","mouth"],
       [ "Blink","eye.slash"],
        ["Move closer","arrow.up.left.and.arrow.down.right"],
        ["Move farther","arrow.down.right.and.arrow.up.left"]
    ]
    private let coreDataPersonRepository: CoreDataPersonRepository
    init(coreDataPersonRepository: CoreDataPersonRepository,faceEmbedingRepository: FaceEmbedingRepository, imageStorageManager: ImageStorageManager) {
        self.faceEmbedingRepository = faceEmbedingRepository
        self.imageStorageManager = imageStorageManager
        self.coreDataPersonRepository = coreDataPersonRepository
        }
    private var currentStepIndex = 0
   
    func nextGuidanceStep() {
        
        DispatchQueue.main.async {
            self.speech.speak(self.guidanceSteps[self.currentStepIndex % self.guidanceSteps.count][0])
            self.guidanceStep = self.guidanceSteps[self.currentStepIndex % self.guidanceSteps.count]
            self.currentStepIndex += 1
            self.delegate?.setGuidanceSteps(self.guidanceStep)
        }
       
    }

  
    func checkDuplicateEmbeding(faceEmbeding:[Float32])->Bool{
        for embeding in self.embedingArray{
            let isSame = faceEmbedingRepository.checkTwoEmbedings(firstEmbeding: faceEmbeding, secondEmbeding: embeding)
           
                if isSame {
                    return true
                }
           
        }
        return false
    }
    func checkWithPreviousEmbeding(faceEmbeding:[Float32])->Bool{
        if self.embedingArray.count <= 0{
            return true
        }
        return !faceEmbedingRepository.checkTwoEmbedingsForSamePerson(firstEmbeding: self.embedingArray.last!, secondEmbeding: faceEmbeding)
       
    }
    func saveFaceImage(_ cgImage: CGImage) {
        if let jpegData = cgImage.jpegData(compressionQuality: 0.8) {
        faceEmbedingRepository.generateEmbedding(from: jpegData) { array in
            if let floatArray = array{
                if !self.checkDuplicateEmbeding(faceEmbeding: floatArray), self.checkWithPreviousEmbeding(faceEmbeding: floatArray){
                    DispatchQueue.main.async {
                        self.photoArray.append(UIImage(cgImage: cgImage))
                        self.embedingArray.append(floatArray)
                        self.savedCount += 1
                        self.delegate?.setPhotoSavedCount(self.savedCount)
                        
                        if self.embedingArray.count >= 200{
                            self.delegate?.setUserNameAlert(true)
                            
                            self.delegate?.stopCapturing()
                            
                        }
                        else{
                            if self.savedCount % 20 == 0{
                                self.nextGuidanceStep()
                            }
                           
                        }
                    }
                }
                
            }
                
            }
        }
     
   }
  
    func saveUser(userName: String, completion: @escaping(Bool) -> Void){
       print("Saved embeding:\(self.embedingArray.count)")
       let id = UUID()
       var urls = [Int]()
       for img in photoArray{
           do{
               let url = try imageStorageManager.saveImage(img, userId: id)
               urls.append(url)
           }
           catch{
               print(error)
           }
       }
       var averageVector: [Float32]?
       if let aveVector =  coreDataPersonRepository.averageVector(from: self.embedingArray){
           averageVector = aveVector
       }
       let person = Person(id: id, name: userName, imageURLs: urls, embedings: self.embedingArray, averageEmbedings: averageVector ?? [0, 0, 0, 0, 0])
       coreDataPersonRepository.savePerson(person) { comp in
           DispatchQueue.main.async {
               self.embedingArray.removeAll()
               self.photoArray.removeAll()
               self.savedCount = 0
               completion(true)
           }
       }
      
      
     
   }
}
