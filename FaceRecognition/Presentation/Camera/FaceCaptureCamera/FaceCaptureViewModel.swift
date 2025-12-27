import Foundation
import Combine
import AVFoundation
import Vision
import UIKit
import SwiftUI

final class FaceCaptureViewModel: NSObject, ObservableObject, CameraDelegate {
    func isCameraRunning(_ isRunning: Bool) {
        DispatchQueue.main.async {
          
            self.isRunning = isRunning
        }
    }
    @Published var guidanceStep: [String] = []
    @Published var savedCount: Int = 0
    @Published var isRunning: Bool = false
    @Published var userName: String = ""
    @Published var userNameAlert: Bool = false
    @Published var selectedLight: LightMode = .none
    var cameraViewModel = CameraViewModel()
    var embedingArray = [[Float32]]()
    var photoArray = [UIImage]()
    //var faceViewModel = FaceViewModel()
    private var cancellables = Set<AnyCancellable>()
    var speech = SpeechManager(isGuidance: true)
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

    private var currentStepIndex = 0
   
    func nextGuidanceStep() {
        
        DispatchQueue.main.async {
            self.speech.speak(self.guidanceSteps[self.currentStepIndex % self.guidanceSteps.count][0])
            self.guidanceStep = self.guidanceSteps[self.currentStepIndex % self.guidanceSteps.count]
            self.currentStepIndex += 1
        }
       
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
                self.selectedLight = .soft
            }
           
            
        }
       
    }
   
    func configure() {
        cameraViewModel.delegate = self
        cameraViewModel.configure()
        self.nextGuidanceStep()
    }
   
    func checkDuplicateEmbeding(faceEmbeding:[Float32])->Bool{
        for embeding in self.embedingArray{
            let isSame = FaceViewModel.shared.checkTwoEmbedings(firstEmbeding: faceEmbeding, secondEmbeding: embeding)
           
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
        return !FaceViewModel.shared.checkTwoEmbedingsForSamePerson(firstEmbeding: self.embedingArray.last!, secondEmbeding: faceEmbeding)
       
    }
   
    // MARK: Save image
     func saveFaceImage(_ cgImage: CGImage) {
        guard isRunning else { return }
        
         guard isRunning else { return }
         FaceViewModel.shared.getEmbedings(image: cgImage) { array in
             if let floatArray = array{
                 if !self.checkDuplicateEmbeding(faceEmbeding: floatArray), self.checkWithPreviousEmbeding(faceEmbeding: floatArray){
                     DispatchQueue.main.async {
                         self.photoArray.append(UIImage(cgImage: cgImage))
                         self.embedingArray.append(floatArray)
                         self.savedCount += 1
                         self.cameraViewModel.savedCount = self.savedCount
                         if self.embedingArray.count >= 200{
                             self.userNameAlert = true
                             self.cameraViewModel.stopCapturing()
                         }
                         else{
                             if self.savedCount % 20 == 0{
                             self.nextGuidanceStep()
                              }
                             if self.savedCount % 33 == 0{
                                 self.nextLightEffect()
                              }
                         }
                                }
                 }

                 
                 
             }
         }
      
    }
   
    func saveUser( completion: @escaping(Bool) -> Void){
        print("Saved embeding:\(self.embedingArray.count)")
        let id = UUID()
        var urls = [Int]()
        for img in photoArray{
            do{
                let url = try ImageStorageManager.shared.saveImage(img, userId: id)
                urls.append(url)
            }
            catch{
                print(error)
            }
        }
        var averageVector: [Float32]?
        if let aveVector =  CoreDataManager.shared.averageVector(from: self.embedingArray){
            averageVector = aveVector
        }
        let person = Person(id: id, name: self.userName, imageURLs: urls, embedings: self.embedingArray, averageEmbedings: averageVector ?? [0, 0, 0, 0, 0])
        CoreDataManager.shared.savePerson(person)
            .sink(receiveCompletion: { comp in
                print(comp)
            }, receiveValue: { recs in
                print(recs)
                DispatchQueue.main.async {
                  
                    self.userName = ""
                    self.embedingArray.removeAll()
                    self.photoArray.removeAll()
                    self.savedCount = 0
                }
            })
            .store(in: &self.cancellables)
       
        completion(true)
    }
    
}

