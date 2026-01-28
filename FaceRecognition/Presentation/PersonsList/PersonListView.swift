//
//  PersonListView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 13/12/25.
//

import SwiftUI
import CoreData
import WebKit
import Combine


struct PersonListView: View {
  
    @State private var showMoreFacesView = false
    @State var userId: UUID = UUID()
    @State var userName: String = ""
    @StateObject  var viewModel: FaceViewModel
    @StateObject var liveStoredPersonList = AllStoredPersonsList.shared
      
    var body: some View {
       
      
                List {
                   
                    ForEach(liveStoredPersonList.faces) { person in
                        
                        NavigationLink {
                            ImageGridView(person: person, onDeleteUrl:{ id,url  in
                                deleteImage(at: id, url: url)
                            })
                            
                        } label: {
                            HStack{
                                Text(person.name)
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                Spacer()
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
            viewModel.deletePerson(personId: AllStoredPersonsList.shared.faces[index].id)
            break
            }
       
        }
    
    private func deleteImage(at id:UUID, url: URL ) {
        if AllStoredPersonsList.shared.faces.first(where: { $0.id == id }) != nil {
            viewModel.deleteImageEmbeding(of: id, imageURL: url)
            //viewModel.deleteImage(at: url)
        }
       
       
        }
   
}

struct ImageGridView: View {
    
    let person: Person
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var onDeleteUrl: ((UUID, URL) -> Void)? = nil
    @State private var showMoreFacesView = false
  
    @State var urls: [URL]?
    private func loadURLs(){
      
        for indx in person.imageURLs{
            do{
                 let url = try ImageStorageManager.shared.getImageURL(userId: person.id, index: indx)
                if urls == nil{
                    urls = [URL]()
                }
                urls?.append(url)
            }
            catch{
                print(error.localizedDescription)
            }
           
        }
       
//        urls = ImageStorageManager.shared.getImageURLs(userId: person.id)

    }
    private func deleteImage(at index: Int) {
       
            if onDeleteUrl != nil{
                onDeleteUrl!(person.id,urls![index])
            }
          
       
        }
    var body: some View {
              ScrollView {
                
                LazyVGrid(columns: columns, spacing: 12) {
                    if let urlList = urls{
                        
                        ForEach(Array(zip(urlList, person.imageURLs)), id: \.0) { url, i in
                            ZStack(alignment: .topTrailing){
                                LocalFileImageView(urlImage: (url, nil, Color.blue))
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Button {
                                        if let index = urls?.firstIndex(of: url) {
                                            deleteImage(at: index)
                                        }
                                    } label: {
                                        HStack{
                                            Text("\(i) : ")
                                                
                                            Image(systemName: "trash.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                    }
                                }
                                
                                .padding(8)
                                .background(
                                    Color.white.opacity(0.50)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                            }
                            }
                       
                    }
                 
                }
                .padding()
            }
              
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                 
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
            MoreFacesRecordView(vm: MoreFacesViewModel(userName: person.name, userId: person.id, moreFacesUseCase: MoreFacesUseCase(faceEmbedingRepository: FaceEmbedingRepository( faceEmbeddingGenerator: FaceEmbeddingGenerator.shared), coreDataPersonRepository: CoreDataPersonRepository(coreDataManager: CoreDataManager.shared), imageStorageManager: ImageStorageManager.shared) ))
                }
        .onAppear {
            loadURLs()
        }
    }
       
}

#Preview {
    PersonListView(viewModel: FaceViewModel(coreDataPersonRepository: CoreDataPersonRepository(coreDataManager: CoreDataManager.shared),  imageStorageManager: ImageStorageManager.shared))
}
