//
//  PersonRepositoryMock.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 11/01/26.
//

import Foundation


final class PersonRepositoryMock: PersonRepository {
    var persons: [Person] = []
    func toPerformAverage()
    {
            for i in 0..<persons.count{
                   
                if let aveEmbeding = self.averageVector(from: persons[i].embedings){
                    persons[i] = Person(id: persons[i].id, name: persons[i].name, imageURLs: persons[i].imageURLs, embedings: persons[i].embedings, averageEmbedings: aveEmbeding)
                        }
            }
    }
    
    func deletePerson(_ personId: UUID, completion: @escaping (Bool) -> Void)
    {
        if let person = persons.first(where: { $0.id == personId }), let index = persons.firstIndex(of: person) {
            persons.remove(at: index)
            completion(true)
            return
        }
        completion(false)
    }
    
    func averageVector(from vectors: [[Float32]]) -> [Float32]?
    {
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
    
    func savePerson(_ person: Person, completion: @escaping (Bool) -> Void) {
        persons.append(person)
        completion(true)
    }
    
    func addEmbedingAndUrls(to personId: UUID, embedings: [[Float32]], urls: [Int], completion: @escaping (Bool) -> Void) {
        if let person = persons.first(where: { $0.id == personId }), let index = persons.firstIndex(of: person) {
            persons[index] = Person(id: personId, name: person.name, imageURLs: person.imageURLs + urls, embedings: person.embedings + embedings, averageEmbedings: self.averageVector(from: person.embedings + embedings)!)
            completion(true)
            return
        }
        completion(false)
    }
    
    func fetchAll() -> [Person]? {
        persons
    }

}
