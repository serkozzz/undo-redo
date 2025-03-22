//
//  ElementCellContentView.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//
import UIKit

class ElementCellContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            update()
        }
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame:.zero)
        setupView()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func update() {
        textView.text = cfg.text
    }
    
    private var cfg: ElementCellContentConfiguration {
        configuration as! ElementCellContentConfiguration
    }
    
    private lazy var textView: UITextView = {
        let resultTextView = UITextView()
        resultTextView.isEditable = true
        resultTextView.isScrollEnabled = false
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultTextView.delegate = self
        return resultTextView
    }()
}


extension ElementCellContentView : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        cfg.onTextEdited?(textView.text)
    }
}

