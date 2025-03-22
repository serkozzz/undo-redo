//
//  DBGenerator.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//

import CoreData

class DBGenerator {
    func generateIfNeeded() {
        
        let fetchRequest: NSFetchRequest<ScreenplayElementDB> = ScreenplayElementDB.fetchRequest()
        let count = try? CoreDataStack.shared.managedContext.count(for: fetchRequest)
        
        guard let padsCount = count, padsCount == 0 else { return }
        
        generate()
    }
    
    private func generate() {
        let context = CoreDataStack.shared.managedContext

        let element1 = ScreenplayElementDB(context: context)
        try! context.obtainPermanentIDs(for: [element1])
        element1.text = "Hello, World!"
        element1.order = 0
        
        let element2 = ScreenplayElementDB(context: context)
        try! context.obtainPermanentIDs(for: [element2])
        element2.text = "It is gorgeous sample of undo redo!"
        element2.order = 1
        
        let element3 = ScreenplayElementDB(context: context)
        try! context.obtainPermanentIDs(for: [element3])
        element3.text = "With best regards - Sergey Kozlov"
        element3.order = 2
        
        do {
            try context.save()
            print("Successfully generated LaunchpadPadDB items")
        } catch {
            print("Failed to save generated items: \(error)")
        }
    }

}
