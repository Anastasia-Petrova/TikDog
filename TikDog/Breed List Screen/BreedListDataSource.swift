//
//  BreedListDataSource.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import UIKit

final class BreedListDataSource: NSObject, UITableViewDataSource, TableDataSource {
    var state: Loadable<[Breed]> {
        didSet {
            update()
        }
    }
    let retryAction: () -> Void
    let tableView: UITableView
    let breedsListPublisher: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    var breedsListRequestSubscription: AnyCancellable?
    
    init(
        initialState: Loadable<[Breed]>,
        tableView: UITableView,
        breedsListPublisher: @escaping () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>,
        retryAction: @escaping () -> Void
    ) {
        self.state = initialState
        self.tableView = tableView
        self.breedsListPublisher = breedsListPublisher
        self.retryAction = retryAction
        
        super.init()
        
        tableView.register(BreedCell.self, forCellReuseIdentifier: BreedCell.identifier)
        tableView.register(BreedCell.Placeholder.self, forCellReuseIdentifier: BreedCell.Placeholder.identifier)
        tableView.register(ErrorMessageCell.self, forCellReuseIdentifier: ErrorMessageCell.identifier)
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
            return makeErrorMessageCell(tableView, indexPath: indexPath, error: error)
            
        case .loading:
            return makePlaceholerCell(tableView, indexPath: indexPath)
            
        case let .loaded(breeds):
            return makeBreedCell(tableView, indexPath: indexPath, breed: breeds[indexPath.row])
        }
    }
    
    private func makeErrorMessageCell(_ tableView: UITableView, indexPath: IndexPath, error: WebError) -> ErrorMessageCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ErrorMessageCell.identifier, for: indexPath) as! ErrorMessageCell
        cell.setMessage(error.message)
        cell.didTapRetryButton = retryAction
        return cell
    }
    
    private func makePlaceholerCell(_ tableView: UITableView, indexPath: IndexPath) -> BreedCell.Placeholder {
        return tableView.dequeueReusableCell(withIdentifier: BreedCell.Placeholder.identifier, for: indexPath) as! BreedCell.Placeholder
    }
    
    private func makeBreedCell(_ tableView: UITableView, indexPath: IndexPath, breed: Breed) -> BreedCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BreedCell.identifier, for: indexPath) as! BreedCell
        cell.setBreed(breed)
        return cell
    }
    
    func fetch() {
        state = .loading
        breedsListRequestSubscription = breedsListPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case let .success(response):
                    self?.state = .loaded(response.breeds)
                    
                case let .failure(error):
                    self?.state = .failed(error)
                }
            }
    }
    
    func getBreed(at indexPath: IndexPath) -> Breed? {
        switch state {
        case let .loaded(breeds):
            return breeds[indexPath.row]
            
        case .failed, .loading:
            return nil
        }
    }
    
    func update() {
        switch state {
        case .loaded:
            tableView.allowsSelection = true
            tableView.isScrollEnabled = true
            
        case .failed, .loading:
            tableView.allowsSelection = false
            tableView.isScrollEnabled = false
        }
        tableView.reloadData()
    }
}
