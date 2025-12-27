//
//  Persons+CoreDataProperties.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 25/12/25.
//
//

import Foundation
import CoreData


extension Persons {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Persons> {
        return NSFetchRequest<Persons>(entityName: "Persons")
    }

    @NSManaged public var embeding: [[Float32]]?
    @NSManaged public var id: UUID?
    @NSManaged public var imageUrls: [Int]?
    @NSManaged public var name: String?
    @NSManaged public var averageEmbeding: [Float32]?

}

extension Persons : Identifiable {

}
