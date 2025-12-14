//
//  CameraUtility.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 12/12/25.
//
import Vision
import CoreImage
import UIKit


class CameraUtility{
    private  func detectFaceLandmarks(_ ciImage: CIImage, completion: @escaping (VNFaceObservation?) -> Void) {
        let request = VNDetectFaceLandmarksRequest { req, err in
            completion(req.results?.first as? VNFaceObservation)
        }
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
        try? handler.perform([request])
    }
    
    private func angleBetweenEyes(_ face: VNFaceObservation, in image: CIImage) -> CGFloat {
        guard
            let leftEye = face.landmarks?.leftEye,
            let rightEye = face.landmarks?.rightEye
        else { return 0 }

        let width = image.extent.width
        let height = image.extent.height

        let left = leftEye.normalizedPoints.first!
        let right = rightEye.normalizedPoints.first!

        let leftPoint = CGPoint(x: face.boundingBox.origin.x * width + left.x * face.boundingBox.width * width,
                                y: face.boundingBox.origin.y * height + left.y * face.boundingBox.height * height)

        let rightPoint = CGPoint(x: face.boundingBox.origin.x * width + right.x * face.boundingBox.width * width,
                                 y: face.boundingBox.origin.y * height + right.y * face.boundingBox.height * height)

        let dy = rightPoint.y - leftPoint.y
        let dx = rightPoint.x - leftPoint.x
        
        return atan2(dy, dx)     // rotation angle in radians
    }
    
    private func rotateImage(_ image: CIImage, angle: CGFloat) -> CIImage {
        let transform = CGAffineTransform(rotationAngle: -angle)
        return image.transformed(by: transform)
    }
    private func cropFace(_ image: CIImage, face: VNFaceObservation) -> CIImage {
        let width = image.extent.width
        let height = image.extent.height
        
        let rect = CGRect(
            x: face.boundingBox.origin.x * width,
            y: face.boundingBox.origin.y * height,
            width: face.boundingBox.width * width,
            height: face.boundingBox.height * height
        )

        return image.cropped(to: rect)
    }
    func extractAlignedFace(from sampleBuffer: CMSampleBuffer, completion: @escaping (CIImage?) -> Void) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        detectFaceLandmarks(ciImage) { faceObs in
            guard let face = faceObs else {
                completion(nil)
                return
            }
            
            // 1️⃣ Get tilt angle
            let angle = self.angleBetweenEyes(face, in: ciImage)

            // 2️⃣ Rotate full image
            let aligned = self.rotateImage(ciImage, angle: angle)

            // 3️⃣ Crop aligned face
            let cropped = self.cropFace(aligned, face: face)
            completion(cropped)
            /*
            // 4️⃣ Convert to UIImage
            let context = CIContext()
            if let cg = context.createCGImage(cropped, from: cropped.extent) {
                completion(UIImage(cgImage: cg))
            } else {
                completion(nil)
            }
             */
        }
    }
    func detectFaceAndBrightness(ciImage: CIImage, completion: @escaping (CGRect?, CGFloat) -> Void) {
            
            let request = VNDetectFaceRectanglesRequest { req, err in
                guard let face = req.results?.first as? VNFaceObservation else {
                    completion(nil, 0)
                    return
                }
                
                let box = face.boundingBox   // normalized rect
                
                // convert to image coordinates
                let width = ciImage.extent.width
                let height = ciImage.extent.height
                
                let rect = CGRect(
                    x: box.minX * width,
                    y: (1 - box.maxY) * height,
                    width: box.width * width,
                    height: box.height * height
                )
                
                // Crop face
                let faceImage = ciImage.cropped(to: rect)
                
                // Compute brightness (luma)
                let brightness = self.computeBrightness(faceImage)
                
                completion(rect, brightness)
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            try? handler.perform([request])
        }
    
    func computeBrightness(_ image: CIImage) -> CGFloat {
           
        let extentVector = CIVector(
              x: image.extent.origin.x,
              y: image.extent.origin.y,
              z: image.extent.size.width,
              w: image.extent.size.height
          )

          guard let filter = CIFilter(name: "CIAreaAverage") else { return 0 }
          filter.setValue(image, forKey: kCIInputImageKey)
          filter.setValue(extentVector, forKey: "inputExtent")

          guard let output = filter.outputImage else { return 0 }

          var bitmap = [UInt8](repeating: 0, count: 4)

          let context = CIContext()
          context.render(output,
                         toBitmap: &bitmap,
                         rowBytes: 4,
                         bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                         format: .RGBA8,
                         colorSpace: nil)

          let r = CGFloat(bitmap[0]) / 255.0
          let g = CGFloat(bitmap[1]) / 255.0
          let b = CGFloat(bitmap[2]) / 255.0

          // luminance formula
          return 0.299*r + 0.587*g + 0.114*b
          
       }
    func normalizeLight(_ ciImage: CIImage, brightness: CGFloat) -> CIImage {
            
            let target: CGFloat = 0.58
            let diff = target - brightness
            
            // Apply brightness adjustment
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.brightness = Float(diff * 1.2)     // increase/decrease
            filter.contrast = 1.05                    // to stabilize features
            filter.saturation = 1.0
            
            return filter.outputImage ?? ciImage
        }
    // Crop face rect -> square CGImage
     func cropFace(from image: CGImage, using obs: VNFaceObservation) -> CGImage? {
        
        let boundingBox = obs.boundingBox   // normalized (0-1)

            // 1. Convert Vision bounding box to pixel coordinates
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)

            // Vision bbox origin is bottom-left; CoreGraphics is top-left → convert
            let rect = CGRect(
                x: boundingBox.origin.x * width,
                y: (1 - boundingBox.origin.y - boundingBox.size.height) * height,
                width: boundingBox.size.width * width,
                height: boundingBox.size.height * height
            )

            // 2. Ensure crop rectangle is inside image bounds
            let safeRect = rect.intersection(CGRect(x: 20, y: 10, width: width-15, height: height))
            if safeRect.isNull || safeRect.isEmpty { return nil }
        if let cropImage =  image.cropping(to: safeRect){
           
           return cropImage
           
        }

        return nil
    }
}
