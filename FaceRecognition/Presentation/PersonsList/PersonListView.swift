//
//  PersonListView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 13/12/25.
//

import SwiftUI

struct PersonListView: View {
  
    @State private var showMoreFacesView = false
    @State var userId: UUID = UUID()
    @State var userName: String = ""
    var body: some View {
        if FaceViewModel.shared.isDeleting{
            ProgressView("Deleting")
        }
        List {
            ForEach(FaceViewModel.shared.faces) { person in
                    
                    NavigationLink {
                        ImageGridView(person: person)
                        
                    } label: {
                        HStack{
                            Text(person.name)
                                .font(.headline)
                                .padding(.vertical, 8)
                            Text("\(person.imageURLs.count)")
                                .font(.headline)
                                .padding(.vertical, 8)
                            
                        }
                    }
                
            }
            .onDelete(perform: deletePerson)
        }
        
               .onAppear {
                  
               }
              
       }
    private func deletePerson(at offsets: IndexSet) {
        for index in offsets {
            FaceViewModel.shared.deletePerson(personId: FaceViewModel.shared.faces[index].id)
            }
       
        }
   
}
struct ImageGridView: View {
    
    let person: Person
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
   
    @State private var showMoreFacesView = false
    @State var userId: UUID = UUID()
    @State var userName: String = ""

    var body: some View {
              ScrollView {
                
                LazyVGrid(columns: columns, spacing: 12) {
                   
                    ForEach(ImageStorageManager.shared.getImageURLs(userId: person.id), id: \.path) { url in
                            LocalFileImageView(url: url)
                        }
                   
//                    ForEach(FaceViewModel.shared.getImages(id: person.id)!, id: \.self) { img in
//                      
//                        Image(uiImage: img)
//                                .resizable()
//                                .scaledToFit()
//                       
//                        
//                    }
                }
                .padding()
            }
              
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    userId = person.id
                    userName = person.name
                    showMoreFacesView = true
                   
                }) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundColor(.black)
                        .imageScale(.large)
                       
                }
            }
            
            ToolbarItem(placement: .principal) {
               
                Text( "Faces View")
                       .font(.headline)
                       .foregroundColor(.primary)
               }
        }
        .navigationDestination(isPresented: $showMoreFacesView) {
            MoreFacesRecordView(vm: MoreFacesViewModel(userName: userName, userId: userId))
                }
    }
}
struct LocalFileImageView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)   // ✅ moved up
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .overlay(
                        Rectangle()
                            .stroke( Color.blue, lineWidth: 4)
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
            print(url.path)
            let img = UIImage(contentsOfFile: url.path)
            DispatchQueue.main.async {
                self.image = img
            }
        }
    }
}
#Preview {
    PersonListView()
}
