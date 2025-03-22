//
//  ElementCellContentConfiguration.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//

import UIKit

class ElementCellContentConfiguration : UIContentConfiguration {

    var text: String?
    var onTextEdited: ((String) -> Void)?
    
    func makeContentView() -> any UIView & UIContentView {
        return ElementCellContentView(self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        self
    }
}
