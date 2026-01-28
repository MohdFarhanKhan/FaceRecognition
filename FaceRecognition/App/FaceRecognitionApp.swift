//
//  FaceRecognitionApp.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 18/12/25.
//

import SwiftUI
import WebKit

@main
struct FaceRecognitionApp: App {
   
    init() {
            // Warm up WebKit to reduce initial delay
            let warmupConfig = WKWebViewConfiguration()
            let warmupWebView = WKWebView(frame: .zero, configuration: warmupConfig)
            warmupWebView.loadHTMLString("<html></html>", baseURL: nil)
        }
    var body: some Scene {
        WindowGroup {
          
            AnimatedSplashView()
              
        }
    }
}
