//
//  FaceGlareRemover.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 04/12/25.
//

import UIKit
import Vision
import CoreImage

class FaceGlareRemover {

    let context = CIContext()
    func giveBrightVariedImages(image: CGImage)->[CGImage]?{
        var images = [CGImage]()
        for i in [  0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]{
            if let img = adjustBrightness(image: image, amount: Float(i)){
                images.append(img)
            }
        }
        return images.count > 0 ? images : nil
    }
    private func adjustBrightness(image: CGImage, amount: Float) -> CGImage? {
       
    let ciImage = CIImage(cgImage: image)

    let filter = CIFilter(name: "CIColorControls")!
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(amount, forKey: kCIInputBrightnessKey)  // -1 to +1

    let context = CIContext()
    if let output = filter.outputImage,
       let cgImage = context.createCGImage(output, from: output.extent) {
        return cgImage
    }

    return nil
  }
    func removeFaceGlare(from image: CGImage, completion: @escaping (CGImage?) -> Void) {
       // detectFace(in: image) { faceRect in
//            guard let faceRect = faceRect else {
//                completion(image)
//                return
//            }
        let output = self.process(image: image, faceRect: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            completion(output)
       // }
    }

    // MARK: - Face Detection
    private func detectFace(in cg: CGImage, completion: @escaping (CGRect?) -> Void) {
       
        let request = VNDetectFaceRectanglesRequest { req, _ in
            let faces = req.results as? [VNFaceObservation]
            completion(faces?.first?.boundingBox)
        }

        let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
        try? handler.perform([request])
    }

    // MARK: - Processing
    private func process(image: CGImage, faceRect: CGRect) -> CGImage? {
       
       let ci = CIImage(cgImage: image)

        let size = ci.extent.size

        // Convert Vision coordinates → Core Image coordinates
        let realFace = CGRect(
            x: faceRect.origin.x * size.width,
            y: (1 - faceRect.origin.y - faceRect.height) * size.height,
            width: faceRect.width * size.width,
            height: faceRect.height * size.height
        )

        // MARK: 1 — Create radial mask (CIRadialGradient)
        let radius = max(realFace.width, realFace.height) * 0.7

        guard
            let gradientFilter = CIFilter(
                name: "CIRadialGradient",
                parameters: [
                    "inputCenter": CIVector(x: realFace.midX, y: realFace.midY),
                    "inputRadius0": radius * 0.3,
                    "inputRadius1": radius,
                    "inputColor0": CIColor.white,
                    "inputColor1": CIColor.clear
                ]
            ),
            let maskImage = gradientFilter.outputImage?
                .cropped(to: ci.extent)
        else { return nil }

        // MARK: 2 — Reduce glare using CIColorControls
        guard
            let colorFilter = CIFilter(name: "CIColorControls")
        else { return nil }

        colorFilter.setValue(ci, forKey: kCIInputImageKey)
        colorFilter.setValue(-0.4, forKey: "inputBrightness")
        colorFilter.setValue(0.7, forKey: "inputContrast")

        guard let glareReduced = colorFilter.outputImage else { return nil }

        // MARK: 3 — Apply glare reduction only on face region
        guard
            let blend = CIFilter(name: "CIBlendWithMask")
        else { return nil }

        blend.setValue(glareReduced, forKey: kCIInputImageKey)
        blend.setValue(ci, forKey: kCIInputBackgroundImageKey)
        blend.setValue(maskImage, forKey: kCIInputMaskImageKey)

        guard let output = blend.outputImage else { return nil }

        // Convert CIImage → UIImage
        if let cg = context.createCGImage(output, from: output.extent) {
            return  cg
        }

        return nil
    }
}
