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
    
    private lazy var undoRedoManager = UndoRedoManager(delegate: self)
    
    override init() {
        super.init()
        do { try fetchedResultsController.performFetch() }
        catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    func element(for id: NSManagedObjectID) -> ScreenplayElement {
        elements.first(where: { $0.id == id })!
    }
    
    var elements: [ScreenplayElement] {
        fetchedResultsController.fetchedObjects!.map { ScreenplayElement($0)}
    }
    
    private var allElementsDB: [ScreenplayElementDB] {
        fetchedResultsController.fetchedObjects!
    }
    
    func setText(for elementID: NSManagedObjectID, text: String) {
        let oldText = element(for: elementID).text
        guard oldText != text else { return }
        doChangeText(elementID: elementID, oldText: oldText, newText: text)
        undoRedoManager.addAction(ScreenplayAction.changeText(itemID: elementID, oldText: oldText, newText: text))
    }
    
    func undo() { undoRedoManager.undo() }
    func redo() { undoRedoManager.redo() }
    
    var canUndo: Bool { undoRedoManager.canUndo }
    var canRedo: Bool { undoRedoManager.canRedo }
    
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


extension ScreenplayModel: UndoRedoManagerDelegate {
    func doChangeText(elementID: NSManagedObjectID, oldText: String, newText: String) {
        let element = allElementsDB.first(where: {$0.objectID == elementID})!
        element.text = newText
        CoreDataStack.shared.saveContext()
        elementChanged.send(elementID)
    }
    
    func undoChangeText(elementID: NSManagedObjectID, oldText: String, newText: String) {
        let element = allElementsDB.first(where: {$0.objectID == elementID})!
        element.text = oldText
        CoreDataStack.shared.saveContext()
        elementChanged.send(elementID)
    }
    
    
}
