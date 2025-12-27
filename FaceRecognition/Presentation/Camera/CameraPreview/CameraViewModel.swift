//
//  CameraViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 05/12/25.
//

import Foundation
import AVFoundation
import Vision
import UIKit
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

protocol CameraDelegate: AnyObject {
    func saveFaceImage(_ cgImage: CGImage)
    func isCameraRunning(_ isRunning: Bool)
   
}

final class CameraViewModel: NSObject{
   
     var isRunning: Bool = false
    var statusText: String = "Idle"
    weak var delegate: CameraDelegate?
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoOutput: AVCaptureVideoDataOutput?
    private var videoConnection: AVCaptureConnection?
    private var ciContext = CIContext()
    let previewView = PreviewView()
    private let faceDetectionService = FaceDetectionService()
    // Vision
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private var processingFrame = false

   
    // Throttle: process every Nth frame to reduce CPU use
    private var frameCounter = 0
    private let frameProcessingStride = 3 // tweak: 1 = every frame, higher = less frequent

    // Padding around face box (in normalized coords)
    private let facePaddingRatio: CGFloat = 0.3
     var targetCount = 200
    var savedCount = 0
    let remover = FaceGlareRemover()
    let cameraUtility = CameraUtility()
    var isConfigure: Bool = false
    override init() {
        super.init()
    }
  
    func configure() {
        if !isConfigure{
            sessionQueue.async {
                self.checkPermissionAndConfigureSession()
            }
        }
        else{
            self.startSession()
        }
    }

    // MARK: Permissions & session setup
    private func checkPermissionAndConfigureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                } else {
                    DispatchQueue.main.async {
                        self.statusText = "Camera permission denied."
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.statusText = "Camera permission denied. Enable in Settings."
            }
        }
    }
  
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo // high resolution

        // Input
        guard let device = defaultCamera() else {
            DispatchQueue.main.async { self.statusText = "No camera available." }
            session.commitConfiguration()
            return
        }
      
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            DispatchQueue.main.async { self.statusText = "Failed to create camera input: \(error)" }
            session.commitConfiguration()
            return
        }

        // Output (video frames)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.output.queue"))
        // BGRA for easy CIImage conversion
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            self.videoOutput = videoOutput
            self.videoConnection = videoOutput.connection(with: .video)
            self.videoConnection?.videoOrientation = .portrait
        }

        session.commitConfiguration()
        isConfigure = true
        DispatchQueue.main.async {
            self.startSession()
        }
    }

    private func defaultCamera() -> AVCaptureDevice? {
      
            if let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                return front
            }
            if let back = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                return back
            }
       
        
       
        return nil
    }

    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
        DispatchQueue.main.async {
            self.statusText = "Ready"
            self.previewView.clearFaceLayers()
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
        DispatchQueue.main.async {
            self.statusText = "Stopped"
            self.isRunning = false
            self.delegate?.isCameraRunning(self.isRunning)
            self.previewView.clearFaceLayers()
        }
    }

    // MARK: Start/Stop capturing faces
    func startCapturing() {
        guard !isRunning else { return }
       
        frameCounter = 0
        DispatchQueue.main.async {
            self.isRunning = true
            self.delegate?.isCameraRunning(self.isRunning)
            self.previewView.clearFaceLayers()
        }
        statusText = "Capturing..."
    }

    func stopCapturing() {
        DispatchQueue.main.async {
          
            self.isRunning = false
            self.statusText = "Stopped"
            self.delegate?.isCameraRunning(self.isRunning)
            self.previewView.clearFaceLayers()
        }
    }

  


   
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var facesObs:  [VNFaceObservation]?
        self.faceDetectionService.detectFaces(pixelBuffer: pixelBuffer, orientation: .leftMirrored) { obs in
            facesObs = obs
        }
        if facesObs?.count == 0{
            DispatchQueue.main.async {
                self.previewView.clearFaceLayers()
                        }
        }
        guard isRunning else { return }
        frameCounter += 1
        if frameCounter % frameProcessingStride != 0 { return }

        if processingFrame { return }
        processingFrame = true
       
        cameraUtility.extractAlignedFace(from: sampleBuffer) { img in
            if let ciImage = img{
              
                self.cameraUtility.detectFaceAndBrightness(ciImage: ciImage) { faceRect, brightness in
                  
        
                    let normalized = self.cameraUtility.normalizeLight(ciImage, brightness: brightness)
                    
                   
                    
                    guard let cgImage = self.ciContext.createCGImage(normalized, from: ciImage.extent) else {
                        self.processingFrame = false
                        print("cgImage nil")
                        return
                    }
                    
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
                    do {
                        try requestHandler.perform([self.faceDetectionRequest])
                        if let results = self.faceDetectionRequest.results as? [VNFaceObservation], !results.isEmpty {
                            for face in results {
                                if !self.isRunning { break }
                                if self.savedCount >= self.targetCount{
                                    
                                    self.stopCapturing()
                                    break
                                }
                                
                               
                                if let faceCrop = self.cameraUtility.cropFace(from: cgImage, using: face) {
                                    if let facesObserve = facesObs{
                                        DispatchQueue.main.async {
                                            self.previewView.updateFaces(facesObserve)
                                            if self.previewView.isAlign{
                                                self.delegate?.saveFaceImage(faceCrop)
                                            }
                                                    }
                                    }
                                    /*
                                    self.remover.removeFaceGlare(from: faceCrop) { faceImg in
                                        if let faceImage = faceImg{
                                            if let facesObserve = facesObs{
                                                DispatchQueue.main.async {
                                                    self.previewView.updateFaces(facesObserve)
                                                    if self.previewView.isAlign{
                                                        self.delegate?.saveFaceImage(faceImage)
                                                    }
                                                            }
                                            }
                                           
                                           
                                            
                                           
                                        }
                                    }
                                    */
                                    
                                }
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.statusText = "Vision error: \(error.localizedDescription)"
                        }
                    }
                    self.processingFrame = false
                }
            }
            else{
                self.processingFrame = false
                return
            }
        }

       
    }
   
   
}
