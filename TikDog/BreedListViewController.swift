//
//  ViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import UIKit

final class BreedListViewController: UITableViewController {
    var state: State
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Row> = {
        let dataSource = UITableViewDiffableDataSource<Section, Row>(tableView: tableView, cellProvider: cellProvider)
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        let section = Section()
        snapshot.appendSections([section])
        let rows = (0...3).map(Row.placeholder)
        snapshot.appendItems(rows, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: false)
        return dataSource
    }()
    
    init(state: BreedListViewController.State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BreedCell.self, forCellReuseIdentifier: BreedCell.identifier)
        tableView.register(BreedPlaceholderCell.self, forCellReuseIdentifier: BreedPlaceholderCell.identifier)
        tableView.dataSource = dataSource
        update(with: state)
    }
    
    func update(with newState: State) {
        var snapshot = dataSource.snapshot()// NSDiffableDataSourceSnapshot<Section, Row>()
        guard let firstSection = snapshot.sectionIdentifiers.first else { return }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: firstSection))
        
//        let section = Section()
//        snapshot.appendSections([section])
        
        let animatingDifferences: Bool
        let rows: [Row]
        switch (state, newState) {
        case (.loading, .loading):
            animatingDifferences = false
            rows = (0...3).map(Row.placeholder)
            
        case let (.loaded, .loaded(breeds)):
            animatingDifferences = true
            rows = breeds.enumerated().map{ index, breed in Row.breed(breed, index: index) }
            
        case (.loaded, .loading):
            animatingDifferences = true
            rows = (0...3).map(Row.placeholder)
            
        case let (.loading, .loaded(breeds)):
            animatingDifferences = false
            rows = breeds.enumerated().map{ index, breed in Row.breed(breed, index: index) }
        }
        
        snapshot.appendItems(rows, toSection: firstSection)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, row: Row) -> UITableViewCell {
        switch row {
        case .placeholder:
            let cell = tableView.dequeueReusableCell(withIdentifier: BreedPlaceholderCell.identifier, for: indexPath) as! BreedPlaceholderCell
            return cell
            
        case let .breed(breed, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: BreedCell.identifier, for: indexPath) as! BreedCell
            cell.setBreed(breed)
            return cell
        }
    }
}

extension BreedListViewController {
    struct Section: Hashable {}
}

extension BreedListViewController {
    enum State {
        case loading
        case loaded([Breed])
    }
    
    enum Row: Hashable {
        case placeholder(index: Int)
        case breed(Breed, index: Int)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .placeholder(index),
                 let .breed(_, index):
                hasher.combine(index)
            }
        }
    }
}

struct Breed: Hashable {
    let name: String
}

class BreedListViewModel {
    
}
