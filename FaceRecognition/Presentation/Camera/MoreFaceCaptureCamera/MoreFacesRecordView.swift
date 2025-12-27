//
//  MoreFacesRecordView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 20/12/25.
//

import SwiftUI

struct MoreFacesRecordView: View {
    //    @State private var faceImages: [[Float32]] = []
    //    @State private var capturedCount = 0
       // @State private var isCapturing = false
     //   @State private var showSuccess = false
     //   @State private var userInput = ""
    @State var isSaving: Bool = false
    @ObservedObject  var vm: MoreFacesViewModel
        @Environment(\.dismiss) var dismiss
       //     @State var shouldGoBack = false
        
        var body: some View {
           
                VStack {
                    if isSaving{
                        ProgressView()
                    }
                    ZStack(alignment: .topTrailing) {
                       
                            CameraPreview(session: vm.cameraViewModel.session, previewView: vm.cameraViewModel.previewView)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                                .padding()
                        LightOverlayView(mode: vm.selectedLight)

                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Saved: \(vm.savedCount)")
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
            
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isSaving = true
                        vm.saveUser { _ in
                            isSaving = false
                            dismiss()
                        }
                       // path.append("faceCapture")
                    }) {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.black)
                            .imageScale(.large)
                           
                    }
                }
                ToolbarItem(placement: .principal) {
                    if vm.guidanceStep.count > 0{
                        HStack{
                            Text( vm.guidanceStep[0])
                                   .font(.headline)
                                   .foregroundColor(.primary)
                            Image(systemName: vm.guidanceStep[1])
                                .resizable()
                                .frame(width: 44, height: 44)
                        }
                    }
                    else{
                        Text( "More Face Record  View")
                               .font(.headline)
                               .foregroundColor(.primary)
                       }
                    }
                    
            }

            .onAppear {
                vm.configure()
               
            }
            .onDisappear { vm.cameraViewModel.stopSession() }
        }
}

#Preview {
    MoreFacesRecordView(vm: MoreFacesViewModel(userName: "Mohd Farhan Khan", userId: UUID()))
}
