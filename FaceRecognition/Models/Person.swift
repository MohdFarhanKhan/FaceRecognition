//
//  Person.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 19/11/25.
//

import Foundation
import UIKit

struct Person: Identifiable, Equatable{
    let id: UUID
    
    let name: String
    let imageURLs: [Int]
    let embedings: [[Float32]]
    let averageEmbedings: [Float32]
   
}



struct MatchModel: Identifiable, Equatable{
    let id = UUID() // Required for Identifiable
    let from:UIImage
    let to: URL?
    let name: String
    let matchPercent: Float
    let isMatched: Bool
}
