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
                            Image(uiImage: matchModel.from)
                                .resizable()
                                .interpolation(.high)   // ✅ moved up
                                .scaledToFill()
                                .frame( height: 180)
                                .clipped()
                                .overlay(
                                    Rectangle()
                                        .stroke(matchModel.isMatched ? Color.green : Color.blue, lineWidth: 4)
                                        .shadow(color: matchModel.isMatched ? .green.opacity(0.6) : .blue.opacity(0.6), radius: 6)
                                )
                            
                            Spacer()
                            if matchModel.to != nil{
                                LocalFileImageView(url: matchModel.to!)
                                /*
                                Image(uiImage: matchModel.to!)
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
                                
                                */
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
