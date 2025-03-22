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
    
    private var dataSource: UICollectionViewDiffableDataSource<String, NSManagedObjectID>!
    private var viewModel = ScreenplayViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        dataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] collectionView, indexPath, id in
            
            guard let self else { return nil }
            let element = viewModel.element(for: id)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            var conf = UIListContentConfiguration.cell()
            conf.text = element.text
            cell.contentConfiguration = conf
            return cell
        }
        
        viewModel.onUpdate = { [weak self] changeType in
            self?.applySnapshot()
        }
        applySnapshot()
    }
    
    func applySnapshot(animating: Bool = true) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: animating)
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
