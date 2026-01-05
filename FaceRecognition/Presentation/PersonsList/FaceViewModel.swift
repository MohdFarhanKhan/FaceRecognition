//
//  FaceViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/11/25.
//

import SwiftUI
import Combine
import CoreData
@MainActor
final class FaceViewModel: NSObject, ObservableObject {
  
    
    @Published var isDeleting: Bool = false
   
   
    private let coreDataPersonRepository: CoreDataPersonRepository
   
    private let imageStorageManager: ImageStorageManager
    init( coreDataPersonRepository: CoreDataPersonRepository, imageStorageManager: ImageStorageManager) {
        
       
        self.coreDataPersonRepository = coreDataPersonRepository
      
        self.imageStorageManager = imageStorageManager
        }
   
    func deletePerson(personId: UUID){
        DispatchQueue.main.async {
            self.isDeleting = true
            self.coreDataPersonRepository.deletePerson(personId) { status in
                self.isDeleting = false
            }
           
        }
    }
    
    func getImages(id: UUID)->[UIImage]?{
        let imgs = imageStorageManager.loadImages(userId: id)
        return imgs
    }
    func deleteImageEmbeding(of id: UUID, imageURL: URL){
        Task{
            do{
                try imageStorageManager.deleteImage(at: imageURL)
                coreDataPersonRepository.deleteEmbeding(of: id, url: imageURL) { status in
                    print(status.description)
                }
            }
            catch{
                print(error.localizedDescription)
            }
            
        }
    }
    func deleteImage( at url: URL){
        Task{
            do{
                try imageStorageManager.deleteImage(at: url)
                coreDataPersonRepository.toPerformAverage()
            }
            catch{
                print(error.localizedDescription)
            }
            
        }
       
    }
    
   
   
}
