
import SwiftUI

final class FaceCaptureViewModel: NSObject, ObservableObject, CameraDelegate , FaceCaptureCameraDelegate{
    func setGuidanceSteps(_ guidanceStep: [String]) {
        self.guidanceStep = guidanceStep
    }
    
    func setUserNameAlert(_ userNameAlert: Bool) {
        DispatchQueue.main.async {
          
            self.userNameAlert = userNameAlert
        }
    }
    
    func setPhotoSavedCount(_ count: Int) {
        DispatchQueue.main.async {
            self.cameraViewModel.savedCount = count
            self.savedCount = count
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
    
    func saveFaceImage(_ cgImage: CGImage) {
        guard isRunning else { return }
        faceCaptureUseCase.saveFaceImage(cgImage)
    }
    
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
   
  private var faceCaptureUseCase: FaceCaptureCameraUseCase
    init(faceCaptureUseCase: FaceCaptureCameraUseCase){
    self.faceCaptureUseCase = faceCaptureUseCase
        }
   
 
   
    func configure() {
        cameraViewModel.delegate = self
        cameraViewModel.configure()
        faceCaptureUseCase.delegate = self
        faceCaptureUseCase.nextGuidanceStep()
       
    }
   
    
   
    func saveUser( completion: @escaping(Bool) -> Void){
        self.faceCaptureUseCase.saveUser(userName: self.userName) { status in
            completion(status)
        }
    }
    
    
}

