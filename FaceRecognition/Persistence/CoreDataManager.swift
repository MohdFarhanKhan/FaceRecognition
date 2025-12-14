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
            if let error = error { fatalError("Core Data load error: \(error)") }
        }
    }

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: - Save / Delete / Fetch
    func savePerson(_ person: Person) -> AnyPublisher<Void, Error> {
        Future { promise in
            let personCoreData = Persons(context: self.context)
            
            personCoreData.name = person.name
            personCoreData.embeding = person.embedings

            do {
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    func savePersonCollection(_ person: Photo) -> AnyPublisher<Void, Error> {
        Future { promise in
            var dataArray: [Data] = []
            for p in person.faces{
                if let data = p.pngData(){
                    dataArray.append(data)
                }
               
            }
            let personCoreData = FacesCollection(context: self.context)
            
            personCoreData.name = person.name
            personCoreData.photos = dataArray

            do {
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    // MARK: - Save / Fetch
    func deletePerson(_ personName: String) -> AnyPublisher<Void, Error> {
       // deletePerson(personName)
        Future { promise in
            
            do {
                if let persons = self.fetchAllPersons(){
                    for p in persons{
                        if p.name! == personName{
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
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    // MARK: - Save / Fetch
    func deleteFaceCollection(_ personName: String) {
        
        do{
                if let persons = self.fetchAllPersonsCollection(){
                    for p in persons{
                        if p.name! == personName{
                            try self.context.delete(p)
                            try self.context.save()
                            break
                        }
                    }
                   
                }
              
            } catch {
                print(error)
            }
       
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
    func fetchAllPersonsCollection() -> [FacesCollection]? {
      
            let request: NSFetchRequest<FacesCollection> = FacesCollection.fetchRequest()
            do {
                let results = try self.context.fetch(request)
                
                return results
                
            } catch {
                return nil
            }
        
       
    }
    func fetchPersons() -> AnyPublisher<[Person], Error> {
        Future { promise in
            let request: NSFetchRequest<Persons> = Persons.fetchRequest()
            do {
                let results = try self.context.fetch(request)
                var persons = [Person]()
                for p in results{
                    
                    persons.append(Person(name: p.name!, embedings: p.embeding!))
                }

                promise(.success(persons))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchPhotos() -> AnyPublisher<[Photo], Error> {
        Future { promise in
            let request: NSFetchRequest<FacesCollection> = FacesCollection.fetchRequest()
            do {
                let results = try self.context.fetch(request)
                var photos = [Photo]()
                for p in results{
                    print(p.photos?[0] ?? "nil data photo")
                    var imgs: [UIImage] = [UIImage]()
                    for d in p.photos!{
                        if let img = UIImage(data: d){
                            imgs.append(img)
                        }
                       
                    }
                   
                    photos.append(Photo( name: p.name!, faces: imgs))
                }

                promise(.success(photos))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }


  
}
