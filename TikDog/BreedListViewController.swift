//
//  ViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedListViewController: UITableViewController {
    lazy var dataSource = BreedListDataSource(initialState: .loading, tableView: tableView)
    var subscription: AnyCancellable?
    let breedListFetcher: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    let didSelectBreed: (Breed) -> Void
    
    init(
        breedListFetcher: @escaping () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>,
        didSelectBreed: @escaping (Breed) -> Void
    ) {
        self.breedListFetcher = breedListFetcher
        self.didSelectBreed = didSelectBreed
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
        
        subscription = breedListFetcher().sink { [weak dataSource] result in
            switch result {
            case let .success(response):
                dataSource?.update(with: .loaded(response.breeds))
            case let .failure(error):
                print(error)
//                dataSource?.update(with: .failed(error))
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSource.forBreedAt(indexPath, perform: didSelectBreed)
    }
}

extension BreedListDataSource {
    enum State {
//        case failed(Error)
        case loaded([Breed])
        case loading
    }
    
    enum Section: Hashable {
        case main
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

struct Breed: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let subBreeds: [Breed]
}

extension Breed {
    init(name: String) {
        self.name = name
        subBreeds = []
    }
}

final class BreedListDataSource: UITableViewDiffableDataSource<BreedListDataSource.Section, BreedListDataSource.Row> {
    var state: State
    
    init(initialState: BreedListDataSource.State, tableView: UITableView) {
        self.state = initialState
        super.init(tableView: tableView, cellProvider: Self.cellProvider)
        var snapshot = NSDiffableDataSourceSnapshot<BreedListDataSource.Section, BreedListDataSource.Row>()
        let section = BreedListDataSource.Section.main
        snapshot.appendSections([section])
        let rows = (0...3).map(BreedListDataSource.Row.placeholder)
        snapshot.appendItems(rows, toSection: section)
        apply(snapshot, animatingDifferences: false)
    }
    
    func forBreedAt(_ indexPath: IndexPath, perform action: (Breed) -> Void) {
        switch state {
        case let .loaded(breeds):
            action(breeds[indexPath.row])
            
        case .loading:
            break
        }
    }
    
    static func cellProvider(_ tableView: UITableView, indexPath: IndexPath, row: Row) -> UITableViewCell {
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
    
    func update(with newState: State) {
        var snapshot = self.snapshot()
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .main))
        
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
        
        snapshot.appendItems(rows, toSection: .main)
        apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
