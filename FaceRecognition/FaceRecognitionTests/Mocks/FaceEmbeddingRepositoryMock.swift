//
//  FaceEmbeddingServiceMock.swift
//  FaceRecognitionTests
//
//  Created by Mohd Khan on 12/01/26.
//

import XCTest

final class FaceEmbeddingRepositoryMock: XCTestCase {

    var embeddingToReturn: [Float32] = []

       func generateEmbedding(from imageData: Data) async throws -> [Float32] {
           embeddingToReturn
       }
}
