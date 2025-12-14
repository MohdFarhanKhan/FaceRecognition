//
//  FacesCollection+CoreDataProperties.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 13/12/25.
//
//

import Foundation
import CoreData


extension FacesCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FacesCollection> {
        return NSFetchRequest<FacesCollection>(entityName: "FacesCollection")
    }

    @NSManaged public var name: String?
    @NSManaged public var photos: [Data]?

}

extension FacesCollection : Identifiable {

}
