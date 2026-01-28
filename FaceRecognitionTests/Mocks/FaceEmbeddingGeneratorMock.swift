//
//  FaceEmbeddingGeneratorMock.swift
//  FaceRecognitionTests
//
//  Created by Mohd Khan on 22/01/26.
//
import XCTest
@testable import FaceRecognition

// ────────────────────────────────────────────────
// MARK: - Mocks
// ────────────────────────────────────────────────

final class FaceEmbeddingGeneratorMock: FaceEmbeddingGenerator {
  
    
    override func isTwoEmbedingsForSamePerson(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        
        return super.isTwoEmbedingsForSamePerson(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
       
    }
    
    override func checkTwoEmbedingsForSamePerson(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        return super.checkTwoEmbedingsForSamePerson(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
       
    }
    
    override func checkTwoEmbedings(firstEmbeding: [Float32], secondEmbeding: [Float32]) -> Bool {
        return super.checkTwoEmbedings(firstEmbeding: firstEmbeding, secondEmbeding: secondEmbeding)
      
    }
    
    override func isSameImages(_ a: [Float32], _ b: [Float32]) -> (Bool, Float) {
        return super.isSameImages(a, b)
       
    }
}
final class FaceEmbedingRepositoryMock: FaceEmbedingRepository {
    
    let generatorMock: FaceEmbeddingGeneratorMock
    
    // Spy / control
    var generatedEmbeddings: [[Data: [Float32]]] = []   // per call
    var checkFacesResult: [(String, Int?, Int?, Float, Bool)] = []
    var checkFacesInDeapResult: [(String, Int?, Int?, Float, Bool)] = []
    
    init(generatorMock: FaceEmbeddingGeneratorMock = FaceEmbeddingGeneratorMock()) {
        self.generatorMock = generatorMock
        super.init(faceEmbeddingGenerator: generatorMock)
    }
    
    // We usually let real logic run, but we can override when needed
    override func checkFaces(faceArray: [[Float32]]) -> [(String, Int?, Int?, Float, Bool)] {
        if !checkFacesResult.isEmpty {
            return checkFacesResult
        }
        return super.checkFaces(faceArray: faceArray)
    }
    
    override func checkFacesInDeap(faceArray: [[Float32]]) -> [(String, Int?, Int?, Float, Bool)] {
        if !checkFacesInDeapResult.isEmpty {
            return checkFacesInDeapResult
        }
        return super.checkFacesInDeap(faceArray: faceArray)
    }
    
    override func generateEmbedding(from image: Data, completion: @escaping ([Float32]?) -> Void) {
        // You can also provide fake embeddings here if you want
        super.generateEmbedding(from: image, completion: completion)
    }
}



// ────────────────────────────────────────────────
// MARK: - Test Class
// ────────────────────────────────────────────────


