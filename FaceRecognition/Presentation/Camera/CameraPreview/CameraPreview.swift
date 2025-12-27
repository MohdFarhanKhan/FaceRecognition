import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    let previewView: PreviewView
    func makeUIView(context: Context) -> PreviewView {
          previewView.videoPreviewLayer.session = session
          previewView.videoPreviewLayer.videoGravity = .resizeAspectFill

          if let connection = previewView.videoPreviewLayer.connection {
              connection.videoOrientation = .portrait
              connection.isVideoMirrored = true
          }

          return previewView
      }

      func updateUIView(_ uiView: PreviewView, context: Context) {}
 
}

