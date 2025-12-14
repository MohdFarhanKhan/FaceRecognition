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
    
    @Published var savedCount: Int = 0
    @Published var isRunning: Bool = false
  
    @Published var userName: String = ""
    @Published var userNameAlert: Bool = false
    var cameraViewModel = CameraViewModel()
    var embedingArray = [[Float32]]()
    var photoArray = [UIImage]()
    var faceViewModel = FaceViewModel()
    private var cancellables = Set<AnyCancellable>()
    var speech = SpeechManager()
    private var guidanceSteps = [
        "Look straight",
        "Look left",
        "Look right",
        "Look up",
        "Look down",
        "Smile",
        "Neutral face",
        "Open mouth",
        "Blink",
        "Move closer",
        "Move farther"
    ]

    private var currentStepIndex = 0

    func nextGuidanceStep() {
        currentStepIndex += 1
      
        speech.speak(guidanceSteps[currentStepIndex % guidanceSteps.count])
    }
 

   
    func configure() {
        cameraViewModel.delegate = self
        cameraViewModel.configure()
        
    }
   

    // MARK: Save image
     func saveFaceImage(_ cgImage: CGImage) {
        guard isRunning else { return }
        /*
        getVariedImages(cgImage: cgImage)
         
         DispatchQueue.main.async {
            
             self.savedCount += 1
             self.cameraViewModel.savedCount = self.savedCount
             if self.savedCount >= 200{
                 self.userNameAlert = true
                 self.cameraViewModel.stopCapturing()
             }
             else if self.savedCount % 20 == 0{
                 self.nextGuidanceStep()
             }
                    }
       
        */
         guard isRunning else { return }
         faceViewModel.getEmbedings(image: cgImage) { array in
             if let floatArray = array{
                 DispatchQueue.main.async {
                     self.photoArray.append(UIImage(cgImage: cgImage))
                     self.embedingArray.append(floatArray)
                     self.savedCount += 1
                     self.cameraViewModel.savedCount = self.savedCount
                     if self.embedingArray.count >= 200{
                         self.userNameAlert = true
                         self.cameraViewModel.stopCapturing()
                     }
                            }
                 
                 
             }
         }
      
    }
   
    func saveUser( completion: @escaping(Bool) -> Void){
        print("Saved embeding:\(self.embedingArray.count)")
        savephotosCollection()
        let person = Person(name: self.userName, embedings: self.embedingArray)
        CoreDataManager.shared.savePerson(person)
            .sink(receiveCompletion: { comp in
                print(comp)
            }, receiveValue: { recs in
                print(recs)
                DispatchQueue.main.async {
                  
                    self.userName = ""
                    self.embedingArray.removeAll()
                    self.savedCount = 0
                }
            })
            .store(in: &self.cancellables)
       
        completion(true)
    }
    func savephotosCollection(){
       
        let person =  Photo(name: userName, faces: photoArray)
        CoreDataManager.shared.savePersonCollection(person)
       
            .sink(receiveCompletion: { comp in
                print(comp)
                self.photoArray.removeAll()
            }, receiveValue: { recs in
                print(recs)
              
            })
            .store(in: &self.cancellables)
    }
}

