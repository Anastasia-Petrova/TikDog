//
//  ViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

protocol TableDataSource: AnyObject, UITableViewDataSource {
    func fetch()
    func getBreed(at indexPath: IndexPath) -> Breed?
    var state: Loadable<[Breed]> { get set }
}

final class BreedListViewController: UITableViewController {
    lazy var dataSource: TableDataSource = BreedListDataSource(
        initialState: .loading,
        tableView: tableView,
        breedsListPublisher: breedListPublisher,
        retryAction: { [weak self] in self?.fetchBreedList() }
    )
    let breedListPublisher: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    let didSelectBreed: (Breed) -> Void
    
    init(
        breedListPublisher: @escaping () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>,
        didSelectBreed: @escaping (Breed) -> Void
    ) {
        self.breedListPublisher = breedListPublisher
        self.didSelectBreed = didSelectBreed
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BreedCell.self, forCellReuseIdentifier: BreedCell.identifier)
        tableView.register(BreedCell.Placeholder.self, forCellReuseIdentifier: BreedCell.Placeholder.identifier)
        tableView.register(ErrorMessageCell.self, forCellReuseIdentifier: ErrorMessageCell.identifier)
        tableView.dataSource = dataSource
        
        fetchBreedList()
    }
    
    private func fetchBreedList() {
        dataSource.fetch()
    }
}

extension BreedListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let breed = dataSource.getBreed(at: indexPath) {
            didSelectBreed(breed)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let placeholderCell = cell as? BreedCell.Placeholder {
            placeholderCell.shimmerView.startAnimating()
        }
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let placeholderCell = cell as? BreedCell.Placeholder {
            placeholderCell.shimmerView.stopAnimating()
        }
    }
}
