//
//  PersonFaceRecord.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/11/25.
//
import SwiftUI
import AVFoundation
import UIKit
import CryptoKit
import Vision   // Required for accurate face cropping

struct PersonFaceRecord: View {
    @State private var faceImages: [[Float32]] = []
    @State private var capturedCount = 0
    @State private var isCapturing = false
    @State private var showSuccess = false
    @State private var userInput = ""
   
    @StateObject private var vm = FaceCaptureViewModel()
    @Environment(\.dismiss) var dismiss
        @State var shouldGoBack = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                CameraPreview(session: vm.cameraViewModel.session)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .padding()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Saved: \(vm.savedCount)/\(vm.cameraViewModel.targetCount)")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    if vm.isRunning {
                        Button(action: vm.cameraViewModel.stopCapturing) {
                            Image(systemName: "stop.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.red)
                        }.padding(.trailing, 8)
                    } else {
                        Button(action: vm.cameraViewModel.startCapturing) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.green)
                        }.padding(.trailing, 8)
                    }
                }.padding()
            }

            
        }
        .navigationTitle("Face Record View")
        .sheet(isPresented: $vm.userNameAlert) {
                    VStack(spacing: 20) {
                        Text("Enter Username")
                            .font(.headline)

                        TextField("Username", text:  $vm.userName)
                            .textFieldStyle(.roundedBorder)
                            .padding()

                        Button("Submit") {
                            vm.userNameAlert = false
                            print("Username: \( $vm.userName)")
                            vm.saveUser { _ in
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancel") {
                            vm.userNameAlert = false
                        }
                    }
                    .padding()
                    .presentationDetents([.height(250)])
                }
        .onAppear {
            vm.configure()
           
        }
        .onDisappear { vm.cameraViewModel.stopSession() }
    }
}

#Preview {
    PersonFaceRecord()
}
