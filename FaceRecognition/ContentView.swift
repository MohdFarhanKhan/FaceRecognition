//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 19/11/25.
//
import SwiftUI
import AVFoundation
import UIKit
import Vision

struct ContentView: View {
    
   
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    @State private var isCapturing = false
  
    @State private var moveToFaceCapture = false
    @StateObject private var vm = FaceCameraViewModel()
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
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
                            .onLongPressGesture {
                                
                            }
                        /*
                        let faceFrame = vm.convertBoundingBox(
                            vm.faceBoundingBox,
                            to: geo.size
                        )
                        FaceGuideOverlay()
                        // Debug — show detected face rectangle
                                       Rectangle()
                                           .stroke(Color.red, lineWidth: 2)
                                           .frame(width: faceFrame.width, height: faceFrame.height)
                                           .position(x: faceFrame.midX, y: faceFrame.midY)
*/
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
                
                        }
           // .navigationTitle("Camera View")
            .onAppear {
                vm.configure()
               
                moveToFaceCapture = false
                if vm.faceViewModel.faces.count <= 0{
                    moveToFaceCapture = true
                }
            }
            .onDisappear {
                vm.cameraViewModel.stopSession()
                vm.matchText = ""
               
            }
        }
    }
}

struct FaceGuideOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width * 0.75, geo.size.height * 0.5)
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: size, height: size)
                .position(x: geo.size.width/2, y: geo.size.height/2)
                .shadow(radius: 10)
        }
        .allowsHitTesting(false)
    }
}
// MARK: - Preview
#Preview {
    ContentView()
}
