//
//  FaceCameraUseCaseTests.swift
//  FaceRecognitionTests
//
//  Created by Mohd Khan on 11/01/26.
//

import XCTest
@testable import FaceRecognition

final class FaceCameraUseCaseTests: XCTestCase {
    func loadIdsImagesFromJSON(fileName: String) -> [IdImages]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                // Configure the date decoding strategy if needed
                decoder.dateDecodingStrategy = .iso8601 // Or another appropriate strategy
                
                // Crucially, decode as an array of your model type: [BlogPost].self
                let blogPosts = try decoder.decode([IdImages].self, from: data)
                return blogPosts
            } catch {
                print("Error decoding JSON file: \(error)")
            }
        }
        return nil
    }

    func convertBase64ToImage(base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    func loadJson(filename fileName: String) -> [Person]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                // Configure the date decoding strategy if needed
                decoder.dateDecodingStrategy = .iso8601 // Or another appropriate strategy

                // Crucially, decode as an array of your model type: [BlogPost].self
                let blogPosts = try decoder.decode([Person].self, from: data)
                return blogPosts
            } catch {
                print("Error decoding JSON file: \(error)")
            }
        }
        return nil
    }
    func test_faceRecognizedSuccessfully() async throws {
            let persons = loadJson(filename: "FaceRecognitionJSONTest")
            let iDImages = loadIdsImagesFromJSON(fileName: "FaceRecognitionImagesJSONForTest")
            let repository = PersonRepositoryMock()
            let embeddingService = FaceEmbeddingServiceMock()
            
        let knownAverageEmbedding: [Float32] = persons![0].averageEmbedings
            let inputEmbedding: [Float32] = persons![0].averageEmbedings
            repository.persons = [
                Person(id: persons![0].id, name: persons![0].name, imageURLs: persons![0].imageURLs, embedings: persons![0].embedings, averageEmbedings: knownAverageEmbedding)
                
            ]

            embeddingService.embeddingToReturn = inputEmbedding
        FaceCameraUseCase(faceEmbedingRepository: <#T##FaceEmbedingRepository#>, imageStorageManager: <#T##ImageStorageManager#>)
            let useCase = RecognizeFaceUseCaseImpl(
                repository: repository,
                embeddingService: embeddingService
            )

            let result = try await useCase.execute(imageData: Data())

            XCTAssertEqual(result.name, "Mohd")
        }

        func test_noMatchingFaceThrowsError() async {

            let repository = PersonRepositoryMock()
            let embeddingService = FaceEmbeddingServiceMock()

            repository.persons = [
                Person(id: UUID(), name: "A", embedding: [0.1, 0.1, 0.1])
            ]

            embeddingService.embeddingToReturn = [0.9, 0.9, 0.9]

            let useCase = RecognizeFaceUseCaseImpl(
                repository: repository,
                embeddingService: embeddingService
            )

            await XCTAssertThrowsError(
                try await useCase.execute(imageData: Data())
            )
        }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
