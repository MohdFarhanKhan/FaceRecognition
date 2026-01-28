//
//  LocalFileImageView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 27/12/25.
//

import SwiftUI

struct LocalFileImageView: View {
    let urlImage: (URL?, UIImage?, Color)
   // let url: URL
    @State private var image: UIImage?
    //@State private var color: Color?
    @State private var showingEnlargedImage = false
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)   
                    .scaledToFit()
                    //.frame(height: 180)
                    .clipped()
                    .overlay(
                        Rectangle()
                            .stroke( urlImage.2, lineWidth: 4)
                            .shadow(color:  .blue.opacity(0.6), radius: 6)
                    )
                    .onLongPressGesture {
                                        
                                        showingEnlargedImage = true
                                    }
                  
                    
            } else {
                Color.gray.opacity(0.2)
               
            }
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            image = nil // 🔥 release memory
        }
        .sheet(isPresented: $showingEnlargedImage) {
            EnlargedImageView(image: Image(uiImage: image!) )
                }
    }

    private func loadImage() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if urlImage.0 != nil{
                let img = UIImage(contentsOfFile: urlImage.0!.path)
                DispatchQueue.main.async {
                    self.image = img
                }
            }
            else{
                DispatchQueue.main.async {
                    self.image = urlImage.1!
                }
            }
            
        }
    }
}
struct EnlargedImageView: View {
    let image: Image
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            image
                .resizable()
                .scaledToFit()
                .ignoresSafeArea(edges: .bottom) // Fill the screen nicely
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    LocalFileImageView(urlImage: (URL(fileURLWithPath: "No url"), nil, Color.blue))
}
