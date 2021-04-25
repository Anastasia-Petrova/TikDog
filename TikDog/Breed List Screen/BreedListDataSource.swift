//
//  BreedListDataSource.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import UIKit

final class BreedListDataSource: NSObject, UITableViewDataSource {
    var state: Loadable<[Breed]> {
        didSet {
            update()
        }
    }
    let retryAction: () -> Void
    let tableView: UITableView
    let breedListPublisher: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    var subscription: AnyCancellable?
    
    init(
        initialState: Loadable<[Breed]>,
        tableView: UITableView,
        breedListPublisher: @escaping () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>,
        retryAction: @escaping () -> Void
    ) {
        self.state = initialState
        self.tableView = tableView
        self.breedListPublisher = breedListPublisher
        self.retryAction = retryAction
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
            return tableView.dequeueReusableCell(withIdentifier: BreedCell.Placeholder.identifier) as! BreedCell.Placeholder
            
        case let .loaded(breeds):
            let breed = breeds[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: BreedCell.identifier, for: indexPath) as! BreedCell
            cell.setBreed(breed)
            return cell
        }
    }
    
    func fetch() {
        state = .loading
        subscription = breedListPublisher()
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
            
        case .failed, .loading:
            tableView.allowsSelection = false
        }
        tableView.reloadData()
    }
}
