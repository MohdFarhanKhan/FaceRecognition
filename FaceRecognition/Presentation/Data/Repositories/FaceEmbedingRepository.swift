//
//  FaceEmbedingRepository.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 30/12/25.
//

import Foundation
import CoreGraphics

final class FaceEmbedingRepository: @preconcurrency EmbedingRepository {
   
   
   
    private let faceEmbeddingGenerator: FaceEmbeddingGenerator
    init( faceEmbeddingGenerator: FaceEmbeddingGenerator) {
            self.faceEmbeddingGenerator = faceEmbeddingGenerator
      
        }
  
    @MainActor func checkFaces(faceArray:[[Float32]])->  [(String, Int?, Int?,Float, Bool)]{
        var matchResults: [(String, Int?, Int?,Float, Bool)] = []
        let aveVector = CoreDataManager.shared.averageVector(from: faceArray)
        var matchResult: (String, Int?, Int?,Float, Bool)?
        for f in AllStoredPersonsList.shared.faces{
            var newMatchResult: (String, Int?, Int?,Float, Bool)?
           
            let match = faceEmbeddingGenerator.isSameImages(f.averageEmbedings, aveVector!)
                if  match.0 == true{
                    for emb in f.embedings{
                        
                    }
                    newMatchResult = (f.name,AllStoredPersonsList.shared.faces.firstIndex(of: f),f.embedings.count/2, match.1*100 , true)
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
       
        if matchResults.count > 0{
            print("\(faceArray.count), \(matchResults)")
        }
        return matchResults
    }
    
    func checkTwoEmbedings(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        faceEmbeddingGenerator.checkTwoEmbedings(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
    }
    
    func checkTwoEmbedingsForSamePerson(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        faceEmbeddingGenerator.checkTwoEmbedingsForSamePerson(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
    }
    
    func generateEmbedding(from image: CGImage, completion: @escaping ([Float32]?) -> Void) {
        faceEmbeddingGenerator.generateEmbedding(from: image) { array in
            completion(array)
        }
    }
    
    
    
}
