//
//  ScreenplayElement.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//

import CoreData


struct ScreenplayElement {
    var text: String
    var id: NSManagedObjectID
    
    init(_ elementDB: ScreenplayElementDB) {
        text = elementDB.text!
        id = elementDB.objectID
    }
}
