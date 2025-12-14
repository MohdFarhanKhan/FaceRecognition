//
//  AnimatedSplashView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 09/12/25.
//

import SwiftUI

struct AnimatedSplashView: View {
    @State private var scale: CGFloat = 1
    @State private var showMain = false
    
    var body: some View {
        ZStack {
            Color.init(red: 78.0/255.0, green: 45.0/255.0, blue: 54.0/255.0)
                            .ignoresSafeArea()
            if showMain {
                ContentView()
            } else {
                Image("SplashScreen")
                    .resizable()
                    //.scaledToFill()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2)) {
                           // scale = 0.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { showMain = true }
                        }
                    }
            }
        }
        
        .ignoresSafeArea()
    }
}
