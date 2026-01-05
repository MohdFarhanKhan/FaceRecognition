//
//  Entities.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 27/12/25.
//

import Foundation


struct Person: Identifiable, Equatable{
    let id: UUID
    let name: String
    let imageURLs: [Int]
    let embedings: [[Float32]]
    let averageEmbedings: [Float32]
   
}

