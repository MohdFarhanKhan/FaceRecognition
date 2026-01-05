//
//  EmbedingRepository.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 30/12/25.
//

import Foundation
import CoreGraphics


protocol EmbedingRepository {
    func checkFaces(faceArray:[[Float32]])->  [(String, Int?, Int?,Float, Bool)]
    func checkTwoEmbedings(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool
    func checkTwoEmbedingsForSamePerson(firstEmbeding:[Float32], secondEmbeding:[Float32] )->Bool
    func generateEmbedding(from image: CGImage,  completion: @escaping([Float32]?) -> Void)
}
