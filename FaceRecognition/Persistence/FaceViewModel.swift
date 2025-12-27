//
//  FaceViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/11/25.
//

import SwiftUI
import CoreData
import Combine
final class FaceViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    static let shared = FaceViewModel()
    @Published var faces: [Person] = []
    @Published var isDeleting: Bool = false
   
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
       
      
    }
   
    func deletePerson(personId: UUID){
        DispatchQueue.main.async {
            self.isDeleting = true
            
            CoreDataManager.shared.deletePerson(personId)
                .sink(receiveCompletion: {[weak self] comp in
                    print(comp)
                    
                    self?.isDeleting = false
                    
                }, receiveValue: { [weak self] recs in
                    print(recs)
                    
                    self?.isDeleting = false
                    Task{
                        try ImageStorageManager.shared.deleteUserFolder(userId: personId)
                    }
                    
                })
                .store(in: &self.cancellables)
        }
    }
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            if let  items = fetchedResultsController.fetchedObjects{
                faces.removeAll()
                for p in items{
                            

                    faces.append(Person(id: p.id!, name: p.name!, imageURLs: p.imageUrls!, embedings: p.embeding!, averageEmbedings: p.averageEmbeding!))
                    print("Urls-> \(faces[0].imageURLs)")
                }
                
            }
        } catch {
            print("Fetch failed: \(error)")
        }
        
    }
    func getImages(id: UUID)->[UIImage]?{
        let imgs = ImageStorageManager.shared.loadImages(userId: id)
        return imgs
    }
    func getEmbedings(image: CGImage, completion: @escaping([Float32]?) -> Void) {
        faceEmbedGenerator.generateEmbedding(from: image) {  floatArray in
            if let array = floatArray{
                completion(array)
            }
            else{
                completion(nil)
            }
        }
        
    }
    
    func checkEmbeding(bedding: [Float32])-> (String, Int?, Int?,Float, Bool)?{
        var matchResult: (String, Int?, Int?,Float, Bool)?
        for f in faces{
           
            print(f.name)
            for emb in f.embedings{
                let match = faceEmbedGenerator.isSameImages(emb, bedding)
                if  match.0 == true{
                    matchResult = (f.name,faces.firstIndex(of: f),f.embedings.firstIndex(of: emb), match.1*100 , true)
                    print("True")
                    return matchResult!
                }
                if matchResult != nil, matchResult!.3 < match.1{
                    matchResult = (f.name,faces.firstIndex(of: f),f.embedings.firstIndex(of: emb), match.1*100, false )
                }
                else  if matchResult == nil{
                    matchResult = (f.name,faces.firstIndex(of: f),f.embedings.firstIndex(of: emb), match.1*100, false )
                }
               
            }
        }
        return matchResult
    }
    
    func checkFaces(faceArray:[[Float32]])->  [(String, Int?, Int?,Float, Bool)]{
        var matchResults: [(String, Int?, Int?,Float, Bool)] = []
        let aveVector = CoreDataManager.shared.averageVector(from: faceArray)
        var matchResult: (String, Int?, Int?,Float, Bool)?
        for f in faces{
            var newMatchResult: (String, Int?, Int?,Float, Bool)?
           
            let match = faceEmbedGenerator.isSameImages(f.averageEmbedings, aveVector!)
                if  match.0 == true{
                    newMatchResult = (f.name,faces.firstIndex(of: f),f.embedings.count/2, match.1*100 , true)
                    if matchResult == nil{
                        matchResult = newMatchResult
                    }
                    else if matchResult!.3 < newMatchResult!.3{
                        matchResult = newMatchResult
                    }
                   
                }
           
        }
        if matchResult != nil{
            matchResults.append(matchResult!)
        }
        /*
        for bedding in faceArray{
            /*
            if let match = checkEmbeding(bedding: bedding){
                matchResults.append(match)
            }
            */

         
            var matchResult: (String, Int?, Int?,Float, Bool)?
            for f in faces{
                var newMatchResult: (String, Int?, Int?,Float, Bool)?
               
                let match = faceEmbedGenerator.isSameImages(f.averageEmbedings, bedding)
                    if  match.0 == true{
                        newMatchResult = (f.name,faces.firstIndex(of: f),f.embedings.count/2, match.1*100 , true)
                        if matchResult == nil{
                            matchResult = newMatchResult
                        }
                        else if matchResult!.3 < newMatchResult!.3{
                            matchResult = newMatchResult
                        }
                       
                    }
               
            }
            if matchResult != nil{
                matchResults.append(matchResult!)
            }
          
        }
         */
        if matchResults.count > 0{
            print("\(faceArray.count), \(matchResults)")
        }
        return matchResults
    }
   
    func checkTwoEmbedings(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool{
        
        let similarity = faceEmbedGenerator.cosineSimilarity(firstEmbeding, secondEmbeding)
       
        return similarity >= 0.98
    }
    func checkTwoEmbedingsForSamePerson(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool{
        
        let similarity = faceEmbedGenerator.cosineSimilarity(firstEmbeding, secondEmbeding)
       
        return similarity >= 0.92
    }
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let  items = fetchedResultsController.fetchedObjects{
            faces.removeAll()
            for p in items{
                if p.id != nil, p.embeding != nil, p.name != nil, p.imageUrls != nil{
                    
                    faces.append(Person(id: p.id!, name: p.name!, imageURLs: p.imageUrls!, embedings: p.embeding!, averageEmbedings: p.averageEmbeding!))
                }
                print("Count:\(faces.count)")
            }
        }
    }
}
