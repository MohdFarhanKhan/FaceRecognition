//
//  LoadPersonClass.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 29/12/25.
//

import Foundation
import CoreData

final class PersonsFetchedResultsObserver: NSObject {

    private let frc: NSFetchedResultsController<Persons>

    var onChange: (([Person]) -> Void)?

    init(context: NSManagedObjectContext) {

        let request: NSFetchRequest<Persons> = Persons.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        frc.delegate = self


    }
    func start() {
            try? frc.performFetch()
            notify()
        }
    private func notify() {
        let persons = frc.fetchedObjects?.map { $0.toDomain() } ?? []
        onChange?(persons)
    }
}

// MARK: - Delegate
extension PersonsFetchedResultsObserver: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        notify()
    }
}
