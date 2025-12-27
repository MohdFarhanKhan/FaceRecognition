//
//  FaceCameraView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 24/12/25.
//

import SwiftUI


struct FaceCameraView: View {
    
   
      @State private var isCapturing = false
  
    @State private var moveToFaceCapture = false
    @StateObject private var vm = FaceCameraViewModel()
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
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
                            
                            
                            if vm.isRunning {
                                Button(action: vm.cameraViewModel.stopCapturing) {
                                    HStack{
                                        Image(systemName: "stop.circle.fill")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .foregroundColor(.red)
                                        
                                    }
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
            }
            .onChange(of: vm.isMatch) { old, new in

                           if new == true {
                               path.append("matchView")
                           }
                       }
            .onChange(of: moveToFaceCapture) { old, new in

                           if new == true {
                               path.append("faceCapture")
                           }
                       }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                        path.append("faceCapture")
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .foregroundColor(.black)
                            .imageScale(.large)
                           
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                       
                        path.append("personList")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.black)
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .principal) {
                   
                    Text( vm.matchText != "" ? vm.matchText : "Camera View")
                           .font(.headline)
                           .foregroundColor(.primary)
                   }
            }
            .navigationDestination(for: String.self) { value in
                            if value == "faceCapture" {
                              
                                PersonFaceRecord( )
                            }
               else  if value == "personList" {
                   PersonListView()
                    //PersonsList()
                }
                else  if value == "matchView" {
                    MatchView()
                 }
                //matchView
                
                        }
           // .navigationTitle("Camera View")
            .onAppear {
                vm.configure()
               
                moveToFaceCapture = false
                if FaceViewModel.shared.faces.count <= 0{
                    moveToFaceCapture = true
                }
            }
            .onDisappear {
                vm.cameraViewModel.stopCapturing()
                vm.cameraViewModel.stopSession()
                vm.matchText = ""
                vm.isMatch = false
            }
        }
    }
}



#Preview {
    FaceCameraView()
}
