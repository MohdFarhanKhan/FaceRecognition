//
//  Extensions.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 07/01/26.
//

import Foundation
import CoreGraphics
import UniformTypeIdentifiers
import ImageIO

extension CGImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        let properties = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
        CGImageDestinationAddImage(destination, self, properties)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
