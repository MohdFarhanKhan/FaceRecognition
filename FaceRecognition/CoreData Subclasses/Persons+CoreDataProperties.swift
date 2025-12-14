//
//  Persons+CoreDataProperties.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 13/12/25.
//
//

import Foundation
import CoreData


extension Persons {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Persons> {
        return NSFetchRequest<Persons>(entityName: "Persons")
    }

    @NSManaged public var embeding: [[Float32]]?
    @NSManaged public var name: String?

}

extension Persons : Identifiable {

}
