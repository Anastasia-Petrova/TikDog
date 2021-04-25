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
            updateCollectionView()
        }
    }
    var subscriptions = Set<AnyCancellable>()
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Row> = {
        UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            collectionView, indexPath, row -> UICollectionViewCell? in
            switch row {
            case let .item(item):
                if let image = item.image {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
                    cell.imageView.image = image
                    return cell
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
                    
                    return collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.Placeholder.identifier, for: indexPath) as! BreedPhotoCell.Placeholder
                }
                
            case let .error(message):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoErrorCell.identifier, for: indexPath) as! BreedPhotoErrorCell
                cell.setMessage(message)
                cell.didTapRetryButton = { [weak self] in self?.fetchBreedPhotos() }
                return cell
                
            case .placeholder:
                return collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.Placeholder.identifier, for: indexPath) as! BreedPhotoCell.Placeholder
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(BreedPhotoCell.self, forCellWithReuseIdentifier: BreedPhotoCell.identifier)
        collectionView.register(BreedPhotoCell.Placeholder.self, forCellWithReuseIdentifier: BreedPhotoCell.Placeholder.identifier)
        collectionView.register(BreedPhotoErrorCell.self, forCellWithReuseIdentifier: BreedPhotoErrorCell.identifier)
        
        collectionView.dataSource = dataSource
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.backgroundColor = .systemGroupedBackground
        updateCollectionView()
        fetchBreedPhotos()
    }
    
    func updateCollectionView() {
        updateScrolling()
        updateDataSource()
    }
    
    func updateScrolling() {
        switch state {
        case .failed, .loading:
            collectionView.isScrollEnabled = false
        case .loaded:
            collectionView.isScrollEnabled = true
        }
    }
    
    func updateDataSource() {
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
            
        case let .failed(error):
            snapshot.appendSections([Section.top])
            snapshot.appendItems([Row.error(error.message)], toSection: Section.top)
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
        if let placeholderCell = cell as? BreedPhotoCell.Placeholder {
            placeholderCell.layoutIfNeeded()
            placeholderCell.shimmerView.startAnimating()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let placeholderCell = cell as? BreedPhotoCell.Placeholder {
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
