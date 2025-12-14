//
//  FaceViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/11/25.
//

import SwiftUI
import CoreData
import Combine
class FaceViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var faces: [Person] = []
    @Published var photos: [Photo] = []
   
    private let fetchedResultsController: NSFetchedResultsController<Persons>
     let faceEmbedGenerator = FaceEmbeddingGenerator()
    private var cancellables = Set<AnyCancellable>()
    override init() {
        let fetchRequest: NSFetchRequest<Persons> = Persons.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Persons.name, ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,  // or your section keyPath
            cacheName: nil)
        
        super.init()
        fetchedResultsController.delegate = self
        
        performFetch()
        loadFacesCollection()
    }
    func loadFacesCollection(){
        self.photos.removeAll()
        CoreDataManager.shared.fetchPhotos()
            .sink(receiveCompletion: { comp in
                print(comp)
            }, receiveValue: { recs in
                self.photos = recs
                
                print(recs)
            })
            .store(in: &self.cancellables)
    }
    func deletePerson(personName: String){
        CoreDataManager.shared.deleteFaceCollection(personName)
        CoreDataManager.shared.deletePerson(personName)
            .sink(receiveCompletion: { comp in
                print(comp)
            }, receiveValue: { recs in
                print(recs)
            })
            .store(in: &self.cancellables)
    }
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            if let  items = fetchedResultsController.fetchedObjects{
                faces.removeAll()
                for p in items{
                    
                    faces.append(Person(name: p.name!, embedings: p.embeding!))
                }
                print("Count:\(faces.count)")
            }
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    func getEmbedings(image: CGImage, completion: @escaping([Float32]?) -> Void) {
        faceEmbedGenerator.generateEmbedding(from: image) { floatArray in
            if let array = floatArray{
                completion(array)
            }
            else{
                completion(nil)
            }
        }
        
    }
    
    func checkBed(bedding: [Float32])-> String{
        
        for f in faces{
            print(f.name)
            for emb in f.embedings{
                if  faceEmbedGenerator.isSameImages(emb, bedding) == true{
                    return f.name
                }
            }
        }
        return ""
    }
    
    func checkFaces(faceArray:[[Float32]])-> String{
       var correct = 0
        var fail = 0
        var name = ""
        for bedding in faceArray{
        
            let personName = checkBed(bedding: bedding)
            if personName != ""{
                name = personName
                correct += 1
                break
            }
            else{
                fail += 1
            }
        }
        print("Correct No:\(correct), FailNo: \(fail)")
        return name
    }
   
    func photoFetch(with name: String, completion: @escaping([Photo]?) -> Void){
        do {
            try fetchedResultsController.performFetch()
            if let  items = fetchedResultsController.fetchedObjects{
                faces.removeAll()
                for p in items{
                    
                    faces.append(Person(name: p.name!, embedings: p.embeding!))
                }
                print("Count:\(faces.count)")
            }
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let  items = fetchedResultsController.fetchedObjects{
            faces.removeAll()
            for p in items{
                
                faces.append(Person(name: p.name!, embedings: p.embeding!))
            }
            print("Count:\(faces.count)")
        }
    }
}
