//
//  BreedPhotosViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedPhotosViewController: UICollectionViewController {
    lazy var dataSource = BreedPhotosDataSource(
        initialState: .loading,
        collectionView: collectionView,
        loadImage: loadImage,
        retryAction: fetchBreedPhotos
    )
    
    var state: Loadable<Page> = .loading {
        didSet {
            applySnapshot()
        }
    }
    var subscriptions = Set<AnyCancellable>()
    lazy var dataSource2: UICollectionViewDiffableDataSource<Section, Row> = {
        UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            collectionView, indexPath, row -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
            switch row {
            case let .item(item):
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
                return cell
                
            case .placeholder:
                
                cell.contentView.backgroundColor = Int.random(in: (0...100)) % 2 == 0 ? .gray : .red
                return cell
            }
        }
    }()
    
    func setImage(_ image: UIImage, indexPath: IndexPath) {
        switch state {
        case var .loaded(page):
            page[indexPath].image = image
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
        collectionView.dataSource = dataSource2
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
            snapshot.appendItems(makePlaceholders(count: 1), toSection: Section.top)
            snapshot.appendItems(makePlaceholders(count: 6), toSection: Section.middle)
            snapshot.appendItems(makePlaceholders(count: 3), toSection: Section.bottom)
            
        case let .loaded(page):
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([Row.item(page.topSection.item)], toSection: Section.top)
            snapshot.appendItems(page.middleSection.items.map(Row.item), toSection: Section.middle)
            snapshot.appendItems(page.bottomSection.items.map(Row.item), toSection: Section.bottom)
            dataSource2.apply(snapshot, animatingDifferences: true)
            
        case .failed:
            snapshot.appendSections([Section.top])
            snapshot.appendItems([Row.error("Error")], toSection: Section.top)
        }
        dataSource2.apply(snapshot, animatingDifferences: true)
    }
    
    func fetchBreedPhotos() {
        dataSource.state = .loading
        subscription = getBreedPhotos()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case let .success(page):
//                    dataSource?.state = .loaded(response.page)
                    self?.state = .loaded(page)
                case let .failure(error):
//                    dataSource?.state = .failed(error)
                    print(error)
                    self?.state = .failed(error)
                }
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
