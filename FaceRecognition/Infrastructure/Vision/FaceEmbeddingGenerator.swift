//
//  FaceEmbeddingGenerator.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/11/25.
//
import Foundation
import UIKit
import Vision
import Accelerate
import CoreML
//import CoreImage

class FaceEmbeddingGenerator {
    
    static let shared = FaceEmbeddingGenerator()
     let threshold: Float = 0.95
   
    func checkTwoEmbedings(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool{
        
        let similarity = cosineSimilarity(firstEmbeding, secondEmbeding)
       
        return similarity >= 0.98
    }
    func isTwoEmbedingsForSamePerson(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool{
        
        let similarity = cosineSimilarity(firstEmbeding, secondEmbeding)
      // print("\(similarity)")
        return similarity >= 0.8
    }
    func checkTwoEmbedingsForSamePerson(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool{
        
        let similarity = cosineSimilarity(firstEmbeding, secondEmbeding)
      // print("\(similarity)")
        return similarity >= 0.92
    }
    func generateEmbedding(from image: Data,  completion: @escaping([Float32]?) -> Void) {
               
                 let request = VNGenerateImageFeaturePrintRequest()
       // VNImageRequestHandler(data: <#T##NSData#>)
                let handler = VNImageRequestHandler(data: image, orientation: .up, options: [:])
                 try? handler.perform([request])
                 guard let obs = request.results?.first as? VNFeaturePrintObservation else {
                     completion(nil)
                     return  }
                 let data = obs.data
                 completion(data.withUnsafeBytes { Array($0.bindMemory(to: Float32.self).prefix(512)) })
           
      
        
    }
     func cosineSimilarity(_ a: [Float32], _ b: [Float32]) -> Float {
         var dot: Float = 0, na: Float = 0, nb: Float = 0
         for i in 0..<512 {
             dot += a[i] * b[i]
             na += a[i] * a[i]
             nb += b[i] * b[i]
         }
         let d = sqrtf(na) * sqrtf(nb)
         return d > 0 ? dot / d : 0
    }
    func isSameImages(_ a: [Float32], _ b: [Float32]) -> (Bool, Float){
        let similarity = cosineSimilarity(a, b)
       
        print("Similarity-> \(similarity)")
        return similarity >= threshold ? (true, similarity) : (false, similarity)
    }
  
    
}
