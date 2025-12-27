//
//  ImageStorageManager.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/12/25.
//

import UIKit

final class ImageStorageManager {

    static let shared = ImageStorageManager()
    private init() {}

    private let fileManager = FileManager.default

    // MARK: - Base Directory
    private var baseDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("users", isDirectory: true)
    }
    func deleteImage(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    func deleteUserFolder(userId: UUID) throws {
        let folder = baseDirectory.appendingPathComponent(userId.uuidString)
        try FileManager.default.removeItem(at: folder)
    }
    func getImageURLs(userId: UUID) -> [URL] {
        let folder = baseDirectory.appendingPathComponent(userId.uuidString)
        return (try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )) ?? []
    }
    func getImageURL(userId: UUID, index: Int) throws ->  URL {
        let folder = try createUserFolder(userId: userId)
        return folder.appendingPathComponent("\(index).png")
        
    }
}
extension ImageStorageManager {

    func createUserFolder(userId: UUID) throws -> URL {
        let userFolder = baseDirectory.appendingPathComponent(userId.uuidString)

        if !fileManager.fileExists(atPath: userFolder.path) {
            try fileManager.createDirectory(
                at: userFolder,
                withIntermediateDirectories: true
            )
        }
        return userFolder
    }
}
extension ImageStorageManager {

    func nextImageIndex(in folder: URL) -> Int {
        let files = (try? fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )) ?? []

        let numbers = files.compactMap {
            Int($0.deletingPathExtension().lastPathComponent)
        }

        return (numbers.max() ?? 0) + 1
    }
}
extension ImageStorageManager {

    func saveImage(_ image: UIImage, userId: UUID) throws -> Int {
        let folder = try createUserFolder(userId: userId)
       
        let index = nextImageIndex(in: folder)

        let imageURL = folder.appendingPathComponent("\(index).png")
        print("Image Size: \(image.size)")
        guard let data =  image.jpegData(compressionQuality: 0.95) else {
            throw NSError(domain: "ImageConversion", code: 0)
        }

        try data.write(to: imageURL, options: .atomic)
        return index
    }
}
extension ImageStorageManager {

    func loadImages(userId: UUID) -> [UIImage] {
        let folder = baseDirectory.appendingPathComponent(userId.uuidString)

        let files = (try? fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )) ?? []

        return files
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .compactMap { UIImage(contentsOfFile: $0.path) }
    }
}

