//
//  MatchModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 31/12/25.
//

import Foundation
import UIKit


struct MatchModel: Identifiable, Equatable{
    let id = UUID() // Required for Identifiable
    let from: Data
    let to: URL?
    let name: String
    let matchPercent: Float
    let isMatched: Bool
}
