//
//  Person.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 19/11/25.
//

import Foundation
import UIKit

struct Person: Identifiable, Equatable{
    var id = UUID() // Required for Identifiable
    
    let name: String
    let embedings: [[Float32]]
}

struct Photo: Identifiable, Equatable{
    var id = UUID() // Required for Identifiable
    let name: String
    let faces: [UIImage]
}

