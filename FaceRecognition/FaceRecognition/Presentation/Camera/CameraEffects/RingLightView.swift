//
//  RingLightView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 18/12/25.
//

import SwiftUI

import SwiftUI

struct RingLightView: View {

    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.45),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 200
                )
            )
            .scaleEffect(pulse ? 1.05 : 0.95)
            .blendMode(.screen)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                    pulse.toggle()
                }
            }
    }
}
#Preview {
    RingLightView()
}
