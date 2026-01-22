//
//  AllStoredPersons.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 01/01/26.
//

import SwiftUI
 @MainActor
final class  AllStoredPersonsList: ObservableObject {

    static let shared = AllStoredPersonsList()

    @Published  var faces: [Person] = []
    
    private var observer: PersonsFetchedResultsObserver
    private   init() {
        observer = PersonsFetchedResultsObserver(context: CoreDataManager.shared.context)
        observer.onChange = { [weak self] persons in
            self?.faces = persons
        }
        observer.start()
    }
   
}
