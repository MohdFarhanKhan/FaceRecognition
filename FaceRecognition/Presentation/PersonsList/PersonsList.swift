//
//  PersonsList.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 28/11/25.
//

import SwiftUI

struct PersonsList: View {
    @ObservedObject var faceViewModel = FaceViewModel()
    @State var deleteProcess = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        if deleteProcess {
                          ProgressView("Deleting...")
                              .padding()
                      }
                    List {
                        ForEach(faceViewModel.faces, id: \.id) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Button(action: {
                                    deleteItemByTap(item: item)
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                }
                            }
                        }
                    }
                    .onChange(of: faceViewModel.faces) { old, new in
                        deleteProcess.toggle()
                                   
                               }
                    .onAppear {
                      
                    }
               
    }
    // Function to delete the item when the button is tapped
    private func deleteItemByTap(item: Person) {
        deleteProcess.toggle()
        faceViewModel.deletePerson(personId: item.id)
       }
}

#Preview {
    PersonsList()
}
