//
//  PersonFaceRecord.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 21/11/25.
//
import SwiftUI

struct PersonFaceRecord: View {

    @StateObject private var vm = FaceCaptureViewModel()
    @Environment(\.dismiss) var dismiss
   
    
    var body: some View {
       
            VStack {
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
        
        
        .toolbar {
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
                    Text( "Face Record  View")
                           .font(.headline)
                           .foregroundColor(.primary)
                   }
                }
                
        }
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
