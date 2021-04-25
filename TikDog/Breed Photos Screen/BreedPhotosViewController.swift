//
//  BreedPhotosViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedPhotosViewController: UICollectionViewController {
    var state: Loadable<Page> = .loading {
        didSet {
            applySnapshot()
        }
    }
    var subscriptions = Set<AnyCancellable>()
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Row> = {
        UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            collectionView, indexPath, row -> UICollectionViewCell? in
            switch row {
            case let .item(item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
                if let image = item.image {
                    cell.imageView.image = image
                } else {
                    let url = item.url
                    self.loadImage(url)
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] image in
                            if let image = image {
                                self?.setImage(image, indexPath: indexPath)
                            }
                        }
                        .store(in: &self.subscriptions)
                }
                return cell
                
            case let .error(message):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
                return cell
                
            case .placeholder:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoPlaceholderCell.identifier, for: indexPath) as! BreedPhotoPlaceholderCell
//                cell.shimmerView.startAnimating()
                return cell
            }
        }
    }()
    
    func setImage(_ image: UIImage, indexPath: IndexPath) {
        switch state {
        case var .loaded(page):
            page[indexPath]?.image = image
            state = .loaded(page)
        default:
            break
        }
    }
    
    let breed: Breed
    let getBreedPhotos: () -> AnyPublisher<Result<Page, WebError>, Never>
    let loadImage: (URL) -> AnyPublisher<UIImage?, Never>
    var subscription: AnyCancellable?
    
    init(
        breed: Breed,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<Page, WebError>, Never>,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>
    ) {
        self.breed = breed
        self.getBreedPhotos = getBreedPhotos
        self.loadImage = loadImage
        super.init(collectionViewLayout: Page.layout)
        view.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(BreedPhotoCell.self, forCellWithReuseIdentifier: BreedPhotoCell.identifier)
        collectionView.register(BreedPhotoPlaceholderCell.self, forCellWithReuseIdentifier: BreedPhotoPlaceholderCell.identifier)
        
        collectionView.dataSource = dataSource
        collectionView.showsVerticalScrollIndicator = false
        applySnapshot()
        fetchBreedPhotos()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        switch state {
        case .loading:
            func makePlaceholders(count: Int) -> [Row] {
                (0..<count).map { _ in Row.placeholder(UUID()) }
            }
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(makePlaceholders(count: Page.Section.Top.numberOfItems), toSection: Section.top)
            snapshot.appendItems(makePlaceholders(count: Page.Section.Middle.numberOfItems), toSection: Section.middle)
            snapshot.appendItems(makePlaceholders(count: Page.Section.Bottom.numberOfItems), toSection: Section.bottom)
            
        case let .loaded(page):
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([Row.item(page.topSection.item)], toSection: Section.top)
            snapshot.appendItems(page.middleSection?.items.map(Row.item) ?? [], toSection: Section.middle)
            snapshot.appendItems(page.bottomSection?.items.map(Row.item) ?? [], toSection: Section.bottom)
            
        case .failed:
            snapshot.appendSections([Section.top])
            snapshot.appendItems([Row.error("Error")], toSection: Section.top)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func fetchBreedPhotos() {
        state = .loading
        subscription = getBreedPhotos()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case let .success(page):
                    self?.state = .loaded(page)
                case let .failure(error):
                    self?.state = .failed(error)
                }
            }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let placeholderCell = cell as? BreedPhotoPlaceholderCell {
            placeholderCell.layoutIfNeeded()
            placeholderCell.shimmerView.startAnimating()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let placeholderCell = cell as? BreedPhotoPlaceholderCell {
            placeholderCell.shimmerView.stopAnimating()
        }
    }
}

extension BreedPhotosViewController {
    enum Section: Hashable, CaseIterable {
        case top
        case middle
        case bottom
    }
    
    enum Row: Hashable {
        case error(String)
        case item(Item)
        case placeholder(UUID)
    }
}
