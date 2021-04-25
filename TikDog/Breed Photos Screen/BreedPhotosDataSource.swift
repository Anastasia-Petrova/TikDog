import Combine
import UIKit

final class BreedPhotosDataSource: UICollectionViewDiffableDataSource<BreedPhotosViewController.Section, BreedPhotosViewController.Row>, CollectionDataSource {
    typealias Row = BreedPhotosViewController.Row
    typealias Section = BreedPhotosViewController.Section
    
    //used for unit testing to mock UUIDs
    static var UUID: () -> UUID = Foundation.UUID.init
    
    var state: Loadable<PhotoPage> = .loading {
        didSet {
            updateCollectionView()
        }
    }
    let getBreedPhotos: () -> AnyPublisher<Result<PhotoPage, WebError>, Never>
    let collectionView: UICollectionView
    var photosRequestSubscription: AnyCancellable?
    
    init(
        collectionView: UICollectionView,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<PhotoPage, WebError>, Never>,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>,
        retryAction: @escaping () -> Void,
        setImage: @escaping (UIImage, IndexPath) -> Void
    ) {
        self.getBreedPhotos = getBreedPhotos
        self.collectionView = collectionView
        collectionView.register(BreedPhotoCell.self, forCellWithReuseIdentifier: BreedPhotoCell.identifier)
        collectionView.register(BreedPhotoCell.Placeholder.self, forCellWithReuseIdentifier: BreedPhotoCell.Placeholder.identifier)
        collectionView.register(BreedPhotoErrorCell.self, forCellWithReuseIdentifier: BreedPhotoErrorCell.identifier)
        
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
    
    private static func makePhotoCell(_ collectionView: UICollectionView, indexPath: IndexPath, image: UIImage) -> BreedPhotoCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
        cell.imageView.image = image
        return cell
    }
    
    private static func makePlaceholderCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> BreedPhotoCell.Placeholder {
        collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.Placeholder.identifier, for: indexPath) as! BreedPhotoCell.Placeholder
    }
    
    private static func makeErrorCell(
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
    
    func updateCollectionView() {
        updateScrollingState()
        updateData()
    }
    
    func updateScrollingState() {
        switch state {
        case .failed, .loading:
            collectionView.isScrollEnabled = false
        case .loaded:
            collectionView.isScrollEnabled = true
        }
    }
    
    static func getSnapshot(for state: Loadable<PhotoPage>) -> NSDiffableDataSourceSnapshot<Section, Row> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        switch state {
        case .loading:
            func makePlaceholders(count: Int) -> [Row] {
                (0..<count).map { _ in Row.placeholder(UUID()) }
            }
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(makePlaceholders(count: PhotoPage.Section.top.numberOfItems), toSection: Section.top)
            snapshot.appendItems(makePlaceholders(count: PhotoPage.Section.middle.numberOfItems), toSection: Section.middle)
            snapshot.appendItems(makePlaceholders(count: PhotoPage.Section.bottom.numberOfItems), toSection: Section.bottom)
            
        case let .loaded(page):
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([BreedPhotosViewController.Row.item(page.topItem)], toSection: Section.top)
            snapshot.appendItems(page.middleSection.map(Row.item), toSection: Section.middle)
            snapshot.appendItems(page.bottomSection.map(Row.item), toSection: Section.bottom)
            
        case let .failed(error):
            snapshot.appendSections([Section.top])
            snapshot.appendItems([BreedPhotosViewController.Row.error(error.message)], toSection: Section.top)
        }
        return snapshot
    }
    
    func updateData() {
        apply(Self.getSnapshot(for: state), animatingDifferences: true)
    }
    
    func fetch() {
        state = .loading
        photosRequestSubscription = getBreedPhotos()
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
