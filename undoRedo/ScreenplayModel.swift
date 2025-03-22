//
//  ScreenPlayRepository.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//
import CoreData
import UIKit
import Combine

class ScreenplayModel: NSObject {
    
    let collectionChanged = PassthroughSubject<NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, Never>()
    let elementChanged = PassthroughSubject<NSManagedObjectID, Never>()
    
    override init() {
        super.init()
        do { try fetchedResultsController.performFetch() }
        catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    var elements: [ScreenplayElement] {
        fetchedResultsController.fetchedObjects!.map { ScreenplayElement($0)}
    }
    
    func setText(for elementID: NSManagedObjectID, text: String) {
        let allElements = fetchedResultsController.fetchedObjects!
        let element = allElements.first(where: {$0.objectID == elementID})!
        element.text = text
        CoreDataStack.shared.saveContext()
        elementChanged.send(elementID)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ScreenplayElementDB> = {
        
        let fetchRequest: NSFetchRequest<ScreenplayElementDB> = ScreenplayElementDB.fetchRequest()
        
        //обязательно нужна какая то сортировка иначе креш
        let nameSort = NSSortDescriptor(key: #keyPath(ScreenplayElementDB.order), ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
    
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: CoreDataStack.shared.managedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "ScreenplayElement")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    

}

extension ScreenplayModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        print(snapshot.itemIdentifiers)
        collectionChanged.send(snapshot)
    }
    
}
