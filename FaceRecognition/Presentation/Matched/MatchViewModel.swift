//
//  MatchViewModel.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 16/12/25.
//
import SwiftUI
 @MainActor
 final class  MatchViewModel: ObservableObject {

    static let shared = MatchViewModel()

    @Published  var matches: [MatchModel] = []

   
}
