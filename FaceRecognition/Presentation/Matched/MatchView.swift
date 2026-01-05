//
//  MatchView.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 16/12/25.
//

import SwiftUI

struct MatchView: View {
    @State var faces: [MatchModel]?
   
    var body: some View {
        List {
            if faces != nil{
                ForEach(faces!) { matchModel in
                    VStack{
                        Text(matchModel.name)
                        Text("\(matchModel.matchPercent)")
                        
                        HStack{
                            LocalFileImageView(urlImage: (nil, matchModel.from, Color.green))
                           
                               
                            
                            Spacer()
                            if matchModel.to != nil{
                                LocalFileImageView(urlImage: (matchModel.to!, nil, Color.blue))
                              
                            }
                        }
                    }
                }
            }
                
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                    Text( "Match View")
                           .font(.headline)
                           .foregroundColor(.primary)
                }
        }
        .onAppear {
            faces = MatchViewModel.shared.matches
        }
    }
}

#Preview {
    MatchView()
}
