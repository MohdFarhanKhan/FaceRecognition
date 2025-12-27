//
//  CoreDataManager.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 19/11/25.
//

import Combine
import CoreData
import UIKit
class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "FaceRecognition")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
            else{
                self.toPerformAverage()
            }
        }
    }

    var context: NSManagedObjectContext { persistentContainer.viewContext }
   
    // MARK: - Save / Delete / Fetch
    func toPerformAverage() {
        Task{
            try await self.updateAverageEmbeddingPersons()
        }
       
    }
    func savePerson(_ person: Person) -> AnyPublisher<Void, Error> {
       
        Future { promise in
            self.persistentContainer.performBackgroundTask { context in
                
                let personCoreData = Persons(context: self.context)

                personCoreData.id = person.id
                personCoreData.name = person.name
                personCoreData.embeding = person.embedings
                
                personCoreData.imageUrls = person.imageURLs
                personCoreData.averageEmbeding = person.averageEmbedings
                do {
                    try self.context.save()
                    
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // MARK: - Save / Fetch
    func addEmbedingAndUrls(to personId: UUID,  embedings: [[Float32]], urls: [Int]) -> AnyPublisher<Void, Error> {
      
        Future { promise in
            self.persistentContainer.performBackgroundTask { context in
                do {
                   let person = try self.fetchPerson(id: personId)
                        person.embeding?.append(contentsOf: embedings)
                        person.imageUrls?.append(contentsOf: urls)
                        person.averageEmbeding = self.averageVector(from: person.embeding!)
                        try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    func deletePerson(_ personId: UUID) -> AnyPublisher<Void, Error> {
      
        Future { promise in
            self.persistentContainer.performBackgroundTask { context in
                do {
                    if let persons = self.fetchAllPersons(){
                        for p in persons{
                            if p.id! == personId{
                                try self.context.delete(p)
                                try self.context.save()
                                break
                            }
                        }
                        
                    }
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
   
    func fetchAllPersons() -> [Persons]? {
      
            let request: NSFetchRequest<Persons> = Persons.fetchRequest()
            do {
                let results = try self.context.fetch(request)
                
                return results
                
            } catch {
                return nil
            }
        
       
    }
    
    func fetchPerson(
        id: UUID
    ) throws -> Persons {

        let request: NSFetchRequest<Persons> = Persons.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let person = try context.fetch(request).first else {
            throw NSError(domain: "PersonNotFound", code: 404)
        }

        return person
    }
    func fetchPersons() -> AnyPublisher<[Person], Error> {
        Future { promise in
            self.persistentContainer.performBackgroundTask { context in
                let request: NSFetchRequest<Persons> = Persons.fetchRequest()
                do {
                    let results = try self.context.fetch(request)
                    var persons = [Person]()
                    for p in results{

                        
                        
                        persons.append(Person(id: p.id!, name: p.name!, imageURLs: p.imageUrls!, embedings: p.embeding!, averageEmbedings: p.averageEmbeding!))
                    }
                    
                    promise(.success(persons))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    func updateAverageEmbeddingPersons() async throws  {
        
        try await self.persistentContainer.performBackgroundTask { [weak self] context in
            print("Start to perform average vector")
            let request: NSFetchRequest<Persons> = Persons.fetchRequest()
            
                let results = try self?.context.fetch(request)
            if results != nil , results!.count >= 0{
                for i in 0..<results!.count{
                    
                    do {
                        if  let embeding = results![i].embeding{
                            if let aveEmbeding = self?.averageVector(from: embeding){
                                results![i].averageEmbeding = aveEmbeding
                                try self?.context.save()
                            }
                        }
                        
                        
                    }
                    catch {
                        print("error to perform average vector-> \(error)")
                    }
                    
                }
                print("End to perform average vector")
            }
        }
    }
    func averageVector(from vectors: [[Float32]]) -> [Float32]? {
        guard !vectors.isEmpty else { return nil }
        
        // Step 1: Validate all vectors have same length
        let dimension = vectors[0].count
        guard vectors.allSatisfy({ $0.count == dimension }) else {
            print("❌ Error: Vectors have inconsistent dimensions!")
            return nil
        }
        
        // Step 2: Sum all vectors element-wise
        let sumVector = vectors.reduce(into: Array(repeating: 0.0 as Float32, count: dimension)) { partialSum, vector in
            for i in 0..<dimension {
                partialSum[i] += vector[i]
            }
        }
        
        // Step 3: Compute average (divide by count)
        let average = sumVector.map { $0 / Float32(vectors.count) }
        
        return average
    }
}
