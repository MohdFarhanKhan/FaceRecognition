//
//  LightOverlayView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 18/12/25.
//
import SwiftUI
enum LightMode: String, CaseIterable {
    case none
    case soft
    case bright
    case left
    case right
    case top
    case ring
}

struct LightOverlayView: View {

    let mode: LightMode

    var body: some View {
        switch mode {

        case .none:
            EmptyView()

        case .soft:
            Color.white
                .opacity(0.2)
                .blendMode(.screen)
                .ignoresSafeArea()

        case .bright:
            Color.white
                .opacity(0.4)
                .blendMode(.screen)
                .ignoresSafeArea()

        case .left:
            LinearGradient(
                colors: [.white.opacity(0.4), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .blendMode(.screen)
            .ignoresSafeArea()

        case .right:
            LinearGradient(
                colors: [.white.opacity(0.4), .clear],
                startPoint: .trailing,
                endPoint: .leading
            )
            .blendMode(.screen)
            .ignoresSafeArea()

        case .top:
            LinearGradient(
                colors: [.white.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.screen)
            .ignoresSafeArea()

        case .ring:
            RingLightView()
        }
    }
}
#Preview {
    LightOverlayView(mode: .none)
}
