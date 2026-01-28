//
//  FaceEmbedingRepository.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 30/12/25.
//

import Foundation
//import CoreGraphics

 class FaceEmbedingRepository: @preconcurrency EmbedingRepository {
   
   
   
    private let faceEmbeddingGenerator: FaceEmbeddingGenerator
    init( faceEmbeddingGenerator: FaceEmbeddingGenerator) {
            self.faceEmbeddingGenerator = faceEmbeddingGenerator
      
        }
    @MainActor func checkFaceInDeap(embeeding:[Float32]) ->  (String, Int?, Int?,Float, Bool)?{
        var matchResult: (String, Int?, Int?,Float, Bool)?
        var matchMaxFailResult: (String, Int?, Int?,Float, Bool)?
        for f in AllStoredPersonsList.shared.faces{
            for embed in f.embedings{
                var newMatchResult: (String, Int?, Int?,Float, Bool)?
                
                let match = faceEmbeddingGenerator.isSameImages(embed, embeeding)
                
                if  match.0 == true{
                    
                    newMatchResult = (f.name,AllStoredPersonsList.shared.faces.firstIndex(of: f),f.embedings.firstIndex(of: embed), match.1*100 , true)
                    if matchResult == nil{
                        matchResult = newMatchResult
                    }
                    else if matchResult!.3 < newMatchResult!.3{
                        matchResult = newMatchResult
                    }
                    
                }
                else if match.1 >= 0.90{
                    if matchMaxFailResult != nil, matchMaxFailResult!.3 < match.1 {
                        matchMaxFailResult = (f.name,AllStoredPersonsList.shared.faces.firstIndex(of: f),f.embedings.firstIndex(of: embed), match.1*100 , false)
                    }
                    else if matchMaxFailResult == nil {
                        matchMaxFailResult = (f.name,AllStoredPersonsList.shared.faces.firstIndex(of: f),f.embedings.firstIndex(of: embed), match.1*100 , false)
                    }
                }
                
            }
        }
        if (matchResult == nil){
            matchResult = matchMaxFailResult
        }
        return matchResult
       
    }
    @MainActor func checkFacesInDeap(faceArray:[[Float32]])->  [(String, Int?, Int?,Float, Bool)]{
        var matchResults: [(String, Int?, Int?,Float, Bool)] = []
        var matchMaxFailResults: [(String, Int?, Int?,Float, Bool)] = []
        for embed in faceArray{
            if let matchResult = self.checkFaceInDeap(embeeding: embed){
                if matchResult.4 {
                    matchResults.append(matchResult)
                }
                else{
                    matchMaxFailResults.append(matchResult)
                }
            }
        }
        if matchResults.count <= 0{
            matchResults = matchMaxFailResults
        }
        
        return matchResults
    }
    @MainActor func checkFaces(faceArray:[[Float32]])->  [(String, Int?, Int?,Float, Bool)]{
        var matchResults: [(String, Int?, Int?,Float, Bool)] = []
        let aveVector = CoreDataManager.shared.averageVector(from: faceArray)
        var matchResult: (String, Int?, Int?,Float, Bool)?
       
        for f in AllStoredPersonsList.shared.faces{
            var newMatchResult: (String, Int?, Int?,Float, Bool)?
           
            let match = faceEmbeddingGenerator.isSameImages(f.averageEmbedings, aveVector!)
           
                if  match.0 == true{
   
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
    func isTwoEmbedingsForSamePerson(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool{
        faceEmbeddingGenerator.isTwoEmbedingsForSamePerson(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
    }
    func checkTwoEmbedings(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        faceEmbeddingGenerator.checkTwoEmbedings(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
    }
    
    func checkTwoEmbedingsForSamePerson(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        faceEmbeddingGenerator.checkTwoEmbedingsForSamePerson(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
    }
    
    func generateEmbedding(from image: Data, completion: @escaping ([Float32]?) -> Void) {
        faceEmbeddingGenerator.generateEmbedding(from: image) { array in
            completion(array)
        }
    }
    
    
    
}
