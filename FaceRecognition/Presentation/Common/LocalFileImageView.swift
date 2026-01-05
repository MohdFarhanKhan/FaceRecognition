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
#Preview {
    LocalFileImageView(urlImage: (URL(fileURLWithPath: "No url"), nil, Color.blue))
}
