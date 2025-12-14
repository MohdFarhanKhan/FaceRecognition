//
//  PersonListView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 13/12/25.
//

import SwiftUI

struct PersonListView: View {
    @ObservedObject var faceViewModel = FaceViewModel()
    var body: some View {
        List {
            ForEach(faceViewModel.photos) { person in
                NavigationLink {
                    ImageGridView(images: person.faces)
                    Spacer()
                } label: {
                    Text(person.name)
                        .font(.headline)
                        .padding(.vertical, 8)
                }
                
            }
            .onDelete(perform: deletePerson)
        }
               .onAppear {
                  
               }
              
       }
    private func deletePerson(at offsets: IndexSet) {
        for index in offsets {
            faceViewModel.deletePerson(personName: faceViewModel.photos[index].name)
            }
       
        }
   
}
struct ImageGridView: View {
    
    let images: [UIImage]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(images, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(12)

                }
            }
            .padding()
        }
       
    }
}
#Preview {
    PersonListView()
}
