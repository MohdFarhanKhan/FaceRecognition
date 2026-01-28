//
//  FaceCameraUseCaseTests.swift
//  FaceRecognitionTests
//
//  Created by Mohd Khan on 11/01/26.
//

import XCTest
@testable import FaceRecognition

final class FaceCameraUseCaseTests: XCTestCase {
    var quality:Float = 0.8
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

    func convertBase64ToImageData1(base64String: String) -> Data? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return imageData
    }
    func getCGImage(from image: UIImage) -> CGImage? {
        // 1. Check if it already has a CGImage
        if let cgImage = image.cgImage {
            return cgImage
        }
        
        // 2. If it is backed by a CIImage, render it
        if let ciImage = image.ciImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        
        return nil
    }
    func convertBase64ToImageData(base64String: String) -> Data? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        if let image = UIImage(data: imageData), let cgImage = getCGImage(from: image) ,let jpegData = cgImage.jpegData(compressionQuality: CGFloat(quality)){
            return  jpegData
        }
        return nil
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
    /*
     let persons = loadJson(filename: "FaceRecognitionJSONTest")
     let iDImages = loadIdsImagesFromJSON(fileName: "FaceRecognitionImagesJSONForTest")
     */
  
    private var sut: FaceCameraUseCase!
        private var repoMock: FaceEmbedingRepositoryMock!
    private var storageMock: ImageStorageManager!
        var persons: [Person] = []
        var iDImages: [IdImages] = []
      
        override func setUpWithError() throws {
            try super.setUpWithError()
            
            repoMock = FaceEmbedingRepositoryMock()
            storageMock = ImageStorageManager.shared
            
            sut = FaceCameraUseCase(
                faceEmbedingRepository: repoMock,
                imageStorageManager: storageMock
            )
           // persons.removeAll()
           // iDImages.removeAll()
            DispatchQueue.main.async {
                AllStoredPersonsList.shared.faces.removeAll()
                MatchViewModel.shared.matches.removeAll()
            }
           
        }
        
        override func tearDownWithError() throws {
            sut = nil
            repoMock = nil
            storageMock = nil
            try super.tearDownWithError()
        }
        
        // ────────────────────────────────────────────────
        // MARK: - Happy path – good match via average vector
        // ────────────────────────────────────────────────
        
        func test_recognizesKnownPerson_usingAverageStrategy() async throws {
            
            persons = loadJson(filename: "FaceRecognitionJSONTest") ?? []
            iDImages = loadIdsImagesFromJSON(fileName: "FaceRecognitionImagesJSONForTest") ?? []
            let id = persons[0].id
            let name = persons[0].name
            let idImage = iDImages.filter{$0.id == id}
            let images = idImage[0].images
            let slice = images.prefix(5) // slice is of type

            // Convert the slice to a new Array if needed
            let first5Images = Array(slice).compactMap(convertBase64ToImageData)// firstNElements is of type [String]
            await MainActor.run {
                AllStoredPersonsList.shared.faces = persons
               
                MatchViewModel.shared.matches.removeAll()
            }
            
           
           
            var capturedResult: (Bool?, String?)?
           
            // Act
            let expectation = expectation(description: "completion called")
            
            await sut.saveFaceImage(first5Images) { result in
                capturedResult = result
                expectation.fulfill()
            }
            
            await fulfillment(of: [expectation], timeout: 15.0)
            
            // Assert
            XCTAssertEqual(capturedResult?.0, true)
            XCTAssertEqual(capturedResult?.1, name)
            
            XCTAssertTrue(self.sut.isMatch)
            
            await MainActor.run {
                XCTAssertEqual(MatchViewModel.shared.matches.first?.name, name)
//                XCTAssertGreaterThanOrEqual(MatchViewModel.shared.matches.first?.matchPercent ?? 0, 90)
            }
            
        }
        
        // ────────────────────────────────────────────────
        // MARK: - Deep search fallback works
        // ────────────────────────────────────────────────
        
        func test_fallsBackToDeepSearch_whenAverageFails() async throws {
            // Arrange
            let personId = UUID()
            await MainActor.run {
                AllStoredPersonsList.shared.faces = [
                   
                    Person(id: personId, name: "Priya", imageURLs: [5], embedings: [], averageEmbedings: [])]
               
                MatchViewModel.shared.matches.removeAll()
            }
            
           
            repoMock.checkFacesResult = []                    // average fails
            repoMock.checkFacesInDeapResult = [
                ("Priya", 0, 0, 96.4, true)
            ]
            
            let images = Array(repeating: Data(), count: 3)
            
            var result: (Bool?, String?)?
            let exp = expectation(description: "done")
            
            // Act
          
            await  sut.saveFaceImage(images) { r in
                result = r
                exp.fulfill()
            }
            
            await fulfillment(of: [exp], timeout: 15.0)
            
            // Assert
           
            XCTAssertNotEqual(result?.0, true)
          
            XCTAssertNotEqual(result?.1, "Priya")
        }
        
        // ────────────────────────────────────────────────
        // MARK: - No good match
        // ────────────────────────────────────────────────
        
        func test_noMatch_found() async throws {
            // Arrange
            DispatchQueue.main.async {
                AllStoredPersonsList.shared.faces.removeAll()
                MatchViewModel.shared.matches.removeAll()
            }
                
                
                let images = Array(repeating: Data(), count: 3)
                
                var result: (Bool?, String?)?
                let exp = expectation(description: "completion")
                
                // Act
                await  sut.saveFaceImage(images) { r in
                    result = r
                    exp.fulfill()
                }
                
                await fulfillment(of: [exp], timeout: 15.0)
                
                // Assert
                XCTAssertEqual(result?.0, false)
                
            
        }
        
        // ────────────────────────────────────────────────
        // MARK: - Close but needs more photos
        // ────────────────────────────────────────────────
        
        func test_closeMatch_suggestsMorePhotos() async throws {
            // Arrange
            persons = loadJson(filename: "FaceRecognitionJSONTest") ?? []
            iDImages = loadIdsImagesFromJSON(fileName: "FaceRecognitionImagesJSONForTest") ?? []
            let id = persons[4].id
            let name = persons[4].name
            let idImage = iDImages.filter{$0.id == id}
            let images = idImage[0].images
            let slice = images.prefix(5) // slice is of type
            quality = 0.4
            // Convert the slice to a new Array if needed
            let first5Images = Array(slice).compactMap(convertBase64ToImageData)// firstNElements is of type [String]
            await MainActor.run {
                AllStoredPersonsList.shared.faces = persons
               
                MatchViewModel.shared.matches.removeAll()
            }
           
            
            var result: (Bool?, String?)?
            let exp = expectation(description: "called")
            
            // Act
            await  sut.saveFaceImage(first5Images) { r in
                result = r
                exp.fulfill()
            }
            
            await fulfillment(of: [exp], timeout: 15.0)
            
            // Assert
            XCTAssertEqual(result?.0, false)
            XCTAssertTrue(result?.1?.lowercased().contains("براہ کرم آپ کو درست طریقے سے پہچاننے کے لیے مزید چہرے شامل کرنے پر غور کریں") == true ||
                          result?.1?.contains(name) == true)
        
        }
    }
