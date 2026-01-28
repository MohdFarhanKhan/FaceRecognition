//
//  CoreDataPersonRepository.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 28/12/25.
//

import Foundation
import Combine
final class CoreDataPersonRepository: PersonRepository {
   
    
    private var cancellables = Set<AnyCancellable>()

    private let coreDataManager: CoreDataManager

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    func fetchAll() -> [Person]? {
        coreDataManager.fetchAll()
    }
    func toPerformAverage() {
        coreDataManager.toPerformAverage()
    }
   
    func deleteEmbeding(of personId: UUID, url: URL, completion: @escaping (Bool) -> Void){
        coreDataManager.deleteEmbedingAndUrls(to: personId, url: url)
            .sink(receiveCompletion: {comp in
                print(comp)
            
                switch comp {
                        case .failure(let error):
                    completion(false)
                        case .finished:
                    completion(true)
                        }
            
                
            }, receiveValue: {  recs in
                print(recs)
               
                
            })
            .store(in: &self.cancellables)
    }
    func deletePerson(_ personId: UUID, completion: @escaping (Bool) -> Void)  {
        coreDataManager.deletePerson(personId)
            .sink(receiveCompletion: {comp in
                print(comp)
            
                switch comp {
                        case .failure(let error):
                    completion(false)
                        case .finished:
                    completion(true)
                        }
            
                
            }, receiveValue: {  recs in
                print(recs)
                
               
                Task{
                    try ImageStorageManager.shared.deleteUserFolder(userId: personId)
                }
               
                
            })
            .store(in: &self.cancellables)
    }
    
    func averageVector(from vectors: [[Float32]]) -> [Float32]? {
        coreDataManager.averageVector(from: vectors)
    }
    
    func savePerson(_ person: Person, completion: @escaping (Bool) -> Void) {
        coreDataManager.savePerson(person)
            .sink(receiveCompletion: { comp in
                print(comp)
            
                switch comp {
                        case .failure(let error):
                    completion(false)
                        case .finished:
                    completion(true)
                        }
             
                
            }, receiveValue: {  recs in
                print(recs)
                
                
            })
            .store(in: &self.cancellables)
    }
    
    func addEmbedingAndUrls(to personId: UUID, embedings: [[Float32]], urls: [Int], completion: @escaping (Bool) -> Void) {
        coreDataManager.addEmbedingAndUrls(to: personId, embedings: embedings, urls: urls)
            .sink(receiveCompletion: { comp in
                print(comp)
            
                switch comp {
                        case .failure(let error):
                    completion(false)
                        case .finished:
                    completion(true)
                        }
             
                
            }, receiveValue: {  recs in
                print(recs)
                
                
            })
            .store(in: &self.cancellables)
    }
    
}
