//
//  ViewController.swift
//  undoRedo
//
//  Created by Sergey Kozlov on 22.03.2025.
//

import UIKit
import CoreData

class ScreenplayViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    private var dataSource: UICollectionViewDiffableDataSource<String, NSManagedObjectID>!
    private var viewModel = ScreenplayViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        undoButton.isEnabled = false
        redoButton.isEnabled = false
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        dataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] collectionView, indexPath, id in
            
            guard let self else { return nil }
            let element = viewModel.element(for: id)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let conf = ElementCellContentConfiguration()
            conf.text = element.text
            conf.onTextEdited = { [weak self] newText in
                guard let self else { return }
                viewModel.setText(for: id, text: newText)
                undoButton.isEnabled = viewModel.canUndo
                redoButton.isEnabled = viewModel.canRedo
            }
            cell.contentConfiguration = conf
            return cell
        }
        
        viewModel.onUpdate = { [weak self] changeType in
            self?.applySnapshot()
        }
        applySnapshot()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    
    func applySnapshot(animating: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            dataSource.apply(viewModel.snapshot, animatingDifferences: animating)
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        viewModel.undo()
        undoButton.isEnabled = viewModel.canUndo
        redoButton.isEnabled = viewModel.canRedo
        
    }
    
    @IBAction func redo(_ sender: Any) {
        viewModel.redo()
        undoButton.isEnabled = viewModel.canUndo
        redoButton.isEnabled = viewModel.canRedo
    }
}


extension ScreenplayViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout () { [self] sectionIndex, environment in
            //guard let self = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}
