//
//  ScreenPlayViewModel.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//

import CoreData
import Combine
import UIKit

class ScreenplayViewModel {
    
    typealias ScreenplaySnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
    private(set) var snapshot: ScreenplaySnapshot!
    
    
    enum ChangeType {
        case collectionUpdated
        case elementUpdated
    }
    
    var onUpdate: ((ChangeType) -> Void)?
    var model = ScreenplayModel()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        model.collectionChanged.sink { [weak self] snapshot in
            guard let self = self else { return }
            self.snapshot = snapshot
            onUpdate?(.collectionUpdated)
        }.store(in: &cancellables)
        
        model.elementChanged.sink { [weak self] id in
            guard let self = self else { return }
            self.snapshot = snapshot
            self.snapshot.reloadItems([id])
            onUpdate?(.elementUpdated)
        }.store(in: &cancellables)
        //you need create first snapshot manually, casuse fetchedResultsController doesn't call its delegate on start
        updateSnapshot()
    }
    
    
    var elements: [ScreenplayElement] {
        model.elements
    }
    
    func element(for id: NSManagedObjectID) -> ScreenplayElement {
        elements.first(where: { $0.id == id })!
    }
    
    func setText(for elementID: NSManagedObjectID, text: String) {
        model.setText(for: elementID, text: text)
    }
    
    private func updateSnapshot() {
        var newSnapshot = ScreenplaySnapshot()
        newSnapshot.appendSections([""])
        newSnapshot.appendItems(model.elements.map { $0.id })
        snapshot = newSnapshot
        onUpdate?(.collectionUpdated)
    }
}
