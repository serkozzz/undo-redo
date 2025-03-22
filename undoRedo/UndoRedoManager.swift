//
//  undoRedoManager.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//

import CoreData

enum ScreenplayAction {
    case changeText(itemID: NSManagedObjectID, oldText: String, newText: String)
}

protocol UndoRedoManagerDelegate: AnyObject {
    func doChangeText(elementID: NSManagedObjectID, oldText: String, newText: String)
    func undoChangeText(elementID: NSManagedObjectID, oldText: String, newText: String)
}

class UndoRedoManager {
    private var undoStack: [ScreenplayAction] = []
    private var redoStack: [ScreenplayAction] = []
    private weak var delegate: UndoRedoManagerDelegate?
    
    init(delegate: UndoRedoManagerDelegate) {
        self.delegate = delegate
    }
    
    func addAction(_ action: ScreenplayAction) {
        undoStack.append(action)
        redoStack.removeAll()
    }

    func undo() {
        guard let action = undoStack.popLast() else { return }
        redoStack.append(action)
        
        switch action {
        case .changeText(let itemID, let oldText, let newText):
            delegate?.undoChangeText(elementID: itemID, oldText: oldText, newText: newText)
        }
    }
        
    func redo() {
        guard let action = redoStack.popLast() else { return }
        undoStack.append(action)
        
        switch action {
        case .changeText(let itemID, let oldText, let newText):
            delegate?.doChangeText(elementID: itemID, oldText: oldText, newText: newText)
        }
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        !redoStack.isEmpty
    }
    
}
