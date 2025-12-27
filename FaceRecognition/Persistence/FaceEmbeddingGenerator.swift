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
import CoreImage

class FaceEmbeddingGenerator {
    
    
    func generateEmbedding(from image: CGImage,  completion: @escaping([Float32]?) -> Void) {

     
               
                 let request = VNGenerateImageFeaturePrintRequest()
                let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
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
       
        print("Similarity->\(similarity)")
        return similarity >= 0.92 ? (true, similarity) : (false, similarity)
    }
  
    
}
