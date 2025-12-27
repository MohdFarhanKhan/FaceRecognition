//
//  PreviewView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 16/12/25.
//

import UIKit
import AVFoundation
import Vision

class PreviewView: UIView {
    var isAlign = false
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    private var faceLayers: [CAShapeLayer] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Public API

    func updateFaces(_ observations: [VNFaceObservation]) {
        clearFaceLayers()

        for observation in observations {
            let faceRect = videoPreviewLayer.layerRectConverted(
                fromMetadataOutputRect: observation.boundingBox
            )
            let circularRect = makeCircularRect(from: faceRect)
            self.isAlign = faceGuideRect().contains(circularRect)

            let layer = CAShapeLayer()
            layer.strokeColor = self.isAlign
                ? UIColor.green.cgColor
                : UIColor.red.cgColor
            layer.lineWidth = 3
            layer.fillColor = UIColor.clear.cgColor
            layer.path = UIBezierPath(
                roundedRect: faceRect,
                cornerRadius: 12
            ).cgPath

            self.layer.addSublayer(layer)
            faceLayers.append(layer)
        }
    }

    // MARK: - Helpers

     func clearFaceLayers() {
        faceLayers.forEach { $0.removeFromSuperlayer() }
        faceLayers.removeAll()
    }
    private func makeCircularRect(from rect: CGRect) -> CGRect {
           let size = min(rect.width, rect.height)
           return CGRect(
               x: rect.midX - size / 2,
               y: rect.midY - size / 2,
               width: size,
               height: size
           )
       }

    private func faceGuideRect() -> CGRect {
        let size = min(bounds.width, bounds.height)
        return CGRect(
            x: (bounds.width - size) / 2,
            y: (bounds.height - size) / 2,
            width: size,
            height: size
        )
    }
}
