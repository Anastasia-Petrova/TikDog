//
//  ViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedListViewController: UITableViewController {
    lazy var dataSource = BreedListDataSource(
        initialState: .loading,
        tableView: tableView,
        retryAction: fetchBreedList
    )
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
        tableView.register(ErrorMessageCell.self, forCellReuseIdentifier: ErrorMessageCell.identifier)
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        fetchBreedList()
    }
    
    func fetchBreedList() {
        dataSource.state = .loading
        subscription = breedListFetcher()
            .receive(on: DispatchQueue.main)
            .sink { [weak dataSource] result in
                switch result {
                case let .success(response):
                    dataSource?.state = .loaded(response.breeds)
                    
                case let .failure(error):
                    dataSource?.state = .failed(error)
                }
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSource.forBreedAt(indexPath, perform: didSelectBreed)
    }
}

final class BreedListDataSource: NSObject, UITableViewDataSource {
    var state: Loadable<[Breed]> {
        didSet {
            update()
        }
    }
    let retryAction: () -> Void
    let tableView: UITableView
    
    init(
        initialState: Loadable<[Breed]>,
        tableView: UITableView,
        retryAction: @escaping () -> Void
    ) {
        self.state = initialState
        self.retryAction = retryAction
        self.tableView = tableView
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .failed:
            return 1
            
        case .loading:
            return 10
            
        case let .loaded(breeds):
            return breeds.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case let .failed(error):
            let cell = tableView.dequeueReusableCell(withIdentifier: ErrorMessageCell.identifier, for: indexPath) as! ErrorMessageCell
            cell.setMessage(error.message)
            cell.didTapRetryButton = retryAction
            return cell
            
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: BreedPlaceholderCell.identifier, for: indexPath) as! BreedPlaceholderCell
            
        case let .loaded(breeds):
            let breed = breeds[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: BreedCell.identifier, for: indexPath) as! BreedCell
            cell.setBreed(breed)
            return cell
        }
    }
    
    func forBreedAt(_ indexPath: IndexPath, perform action: (Breed) -> Void) {
        switch state {
        case let .loaded(breeds):
            action(breeds[indexPath.row])
            
        case .failed, .loading:
            break
        }
    }
    
    func update() {
        switch state {
        case .loaded:
            tableView.allowsSelection = true
            
        case .failed, .loading:
            tableView.allowsSelection = false
        }
        tableView.reloadData()
    }
}
