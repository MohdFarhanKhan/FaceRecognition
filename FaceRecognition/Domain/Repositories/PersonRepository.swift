//
//  PersonRepository.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 28/12/25.
//

import Foundation
import Combine

protocol PersonRepository {
    func toPerformAverage()
    func deletePerson(_ personId: UUID, completion: @escaping (Bool) -> Void)
    func averageVector(from vectors: [[Float32]]) -> [Float32]?
    func savePerson(_ person: Person,  completion: @escaping (Bool) -> Void)
    func addEmbedingAndUrls(to personId: UUID,  embedings: [[Float32]], urls: [Int], completion: @escaping (Bool) -> Void)
}
