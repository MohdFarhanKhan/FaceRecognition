//
//  Entities.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 27/12/25.
//

import Foundation


struct Person: Identifiable, Equatable, Codable{
    let id: UUID
    let name: String
    let imageURLs: [Int]
    let embedings: [[Float32]]
    let averageEmbedings: [Float32]
   
}



// Main model containing an array of image data
struct IdImages: Codable {
    let id: UUID
    let images: [String] // Array of images in form of base64string
}
