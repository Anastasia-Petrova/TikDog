import Combine
import UIKit

final class BreedPhotosDataSource: UICollectionViewDiffableDataSource<BreedPhotosViewController.Section, BreedPhotosViewController.Row> {
    typealias Row = BreedPhotosViewController.Row
    typealias Section = BreedPhotosViewController.Section
    
    var state: Loadable<Photos> = .loading {
        didSet {
            updateCollectionView()
        }
    }
    let getBreedPhotos: () -> AnyPublisher<Result<Photos, WebError>, Never>
    let collectionView: UICollectionView
    var subscription: AnyCancellable?
    
    init(
        collectionView: UICollectionView,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<Photos, WebError>, Never>,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>,
        retryAction: @escaping () -> Void,
        setImage: @escaping (UIImage, IndexPath) -> Void
    ) {
        self.getBreedPhotos = getBreedPhotos
        self.collectionView = collectionView
        var subscriptions = Set<AnyCancellable>()
        
        super.init(collectionView: collectionView) { collectionView, indexPath, row -> UICollectionViewCell? in
            switch row {
            case let .item(item):
                if let image = item.image {
                    return Self.makePhotoCell(collectionView, indexPath: indexPath, image: image)
                } else {
                    loadImage(item.url)
                        .receive(on: DispatchQueue.main)
                        .sink { image in
                            if let image = image {
                                setImage(image, indexPath)
                            }
                        }
                        .store(in: &subscriptions)
                    
                    return Self.makePlaceholderCell(collectionView, indexPath: indexPath)
                }
                
            case let .error(message):
                return Self.makeErrorCell(
                    collectionView,
                    indexPath: indexPath,
                    message: message,
                    retryAction: retryAction
                )
                
            case .placeholder:
                return Self.makePlaceholderCell(collectionView, indexPath: indexPath)
            }
        }
    }
    
    static func makePhotoCell(_ collectionView: UICollectionView, indexPath: IndexPath, image: UIImage) -> BreedPhotoCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
        cell.imageView.image = image
        return cell
    }
    
    
    static func makePlaceholderCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> BreedPhotoCell.Placeholder {
        collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.Placeholder.identifier, for: indexPath) as! BreedPhotoCell.Placeholder
    }
    
    static func makeErrorCell(
        _ collectionView: UICollectionView,
        indexPath: IndexPath,
        message: String,
        retryAction: @escaping () -> Void
    ) -> BreedPhotoErrorCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoErrorCell.identifier, for: indexPath) as! BreedPhotoErrorCell
        cell.setMessage(message)
        cell.didTapRetryButton = retryAction
        return cell
    }
    
    private func updateCollectionView() {
        updateScrollingState()
        updateData()
    }
    
    private func updateScrollingState() {
        switch state {
        case .failed, .loading:
            collectionView.isScrollEnabled = false
        case .loaded:
            collectionView.isScrollEnabled = true
        }
    }
    
    private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        switch state {
        case .loading:
            func makePlaceholders(count: Int) -> [Row] {
                (0..<count).map { _ in Row.placeholder(UUID()) }
            }
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(makePlaceholders(count: PhotosPage.Section.Top.numberOfItems), toSection: Section.top)
            snapshot.appendItems(makePlaceholders(count: PhotosPage.Section.Middle.numberOfItems), toSection: Section.middle)
            snapshot.appendItems(makePlaceholders(count: PhotosPage.Section.Bottom.numberOfItems), toSection: Section.bottom)
            
        case let .loaded(page):
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([BreedPhotosViewController.Row.item(page.topItem)], toSection: Section.top)
            snapshot.appendItems(page.middleSection.map(Row.item), toSection: Section.middle)
            snapshot.appendItems(page.bottomSection.map(Row.item), toSection: Section.bottom)
            
//            snapshot.appendItems([BreedPhotosViewController.Row.item(page.topSection.item)], toSection: Section.top)
//            snapshot.appendItems(page.middleSection?.items.map(Row.item) ?? [], toSection: Section.middle)
//            snapshot.appendItems(page.bottomSection?.items.map(Row.item) ?? [], toSection: Section.bottom)
            
        case let .failed(error):
            snapshot.appendSections([Section.top])
            snapshot.appendItems([BreedPhotosViewController.Row.error(error.message)], toSection: Section.top)
        }
        apply(snapshot, animatingDifferences: true)
    }
    
    func fetch() {
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
    
    func setImage(_ image: UIImage, indexPath: IndexPath) {
        switch state {
        case var .loaded(page):
            page[indexPath].image = image
            state = .loaded(page)
        default:
            break
        }
    }
}

struct Photos {
    var topItem: Item
    var middleSection: [Item]
    var bottomSection: [Item]
    
    static let numberOfItemsInTopSecton = 1
    static let numberOfItemsInMiddleSecton = 6
    static let numberOfItemsInBottomSecton = 3
    
    subscript(indexPath: IndexPath) -> Item {
        get {
            switch (indexPath.section, indexPath.row) {
            case (0, 0..<Self.numberOfItemsInTopSecton):
                return topItem
                
            case (1, 0..<Self.numberOfItemsInMiddleSecton):
                return middleSection[indexPath.row]
                
            case (2, 0..<Self.numberOfItemsInBottomSecton):
                return bottomSection[indexPath.row]
                
            default:
                fatalError("Index out of range")
            }
        }
        set {
            switch (indexPath.section, indexPath.row) {
            case (0, 0..<Self.numberOfItemsInTopSecton):
                topItem = newValue
                
            case (1, 0..<Self.numberOfItemsInMiddleSecton):
                
                middleSection[indexPath.row] = newValue
            case (2, 0..<Self.numberOfItemsInBottomSecton):
                bottomSection[indexPath.row] = newValue
                
            default:
                fatalError("Index out of range")
            }
        }
    }
}

extension Photos: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urls = try container.decode([URL].self, forKey: .message)
        
        guard let firstURL = urls.first else {
            throw DecodingError.typeMismatch(
                PhotosPage.self,
                DecodingError.Context(codingPath: [], debugDescription: "Expected to get at least one URL")
            )
        }
        topItem = Item(url: firstURL)
        middleSection = []
        bottomSection = []
        for (index, url) in urls.enumerated() {
            switch index {
            case (1...6):
                middleSection.append(Item(url: url))
                
            case (7...10):
                bottomSection.append(Item(url: url))
            default:
                break
            }
        }
    }
}
