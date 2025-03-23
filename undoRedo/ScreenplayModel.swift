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
    
    private lazy var undoManager = UndoManager()
    
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
    
    
    
    func registerChangeTextUndo(element: ScreenplayElementDB, oldText: String, newText: String) {
        undoManager.registerUndo(withTarget: self) { screenplayModel in
            element.text = oldText
            CoreDataStack.shared.saveContext()
            screenplayModel.elementChanged.send(element.objectID)
            screenplayModel.registerChangeTextRedo(element: element, oldText: oldText, newText: newText)
        }
    }
    
    
    func registerChangeTextRedo(element: ScreenplayElementDB, oldText: String, newText: String) {
        undoManager.registerUndo(withTarget: self) { screenplayModel in
            element.text = newText
            CoreDataStack.shared.saveContext()
            screenplayModel.elementChanged.send(element.objectID)
            screenplayModel.registerChangeTextUndo(element: element, oldText: oldText, newText: newText)
        }
    }

    
    func setText(for elementID: NSManagedObjectID, text: String) {
        let oldText = element(for: elementID).text
        guard oldText != text else { return }
        
        let element = allElementsDB.first(where: {$0.objectID == elementID})!
        
        registerChangeTextUndo(element: element, oldText: oldText, newText: text)
        
        element.text = text
        CoreDataStack.shared.saveContext()
        elementChanged.send(elementID)
    }
    
    func undo() { undoManager.undo() }
    func redo() { undoManager.redo() }
    
    var canUndo: Bool { undoManager.canUndo }
    var canRedo: Bool { undoManager.canRedo }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ScreenplayElementDB> = {
        
        let fetchRequest: NSFetchRequest<ScreenplayElementDB> = ScreenplayElementDB.fetchRequest()
        
        //обязательно нужна какая то сортировка иначе креш
        let orderSort = NSSortDescriptor(key: #keyPath(ScreenplayElementDB.order), ascending: true)
        fetchRequest.sortDescriptors = [orderSort]
    
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
