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
        collectionView: collectionView,
        getBreedPhotos: breedPhotosPublisher,
        loadImage: loadImage,
        retryAction: { [weak self] in self?.fetchBreedPhotos() },
        setImage: { [weak self] in self?.setImage($0, indexPath: $1) }
    )

    let breedPhotosPublisher: () -> AnyPublisher<Result<Photos, WebError>, Never>
    let loadImage: (URL) -> AnyPublisher<UIImage?, Never>
    
    init(
        breedPhotosPublisher: @escaping () -> AnyPublisher<Result<Photos, WebError>, Never>,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>
    ) {
        self.breedPhotosPublisher = breedPhotosPublisher
        self.loadImage = loadImage
        super.init(collectionViewLayout: Self.collectionLayout)
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
        fetchBreedPhotos()
    }
    
    func fetchBreedPhotos() {
        dataSource.fetch()
    }
    
    func setImage(_ image: UIImage, indexPath: IndexPath) {
        dataSource.setImage(image, indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let placeholderCell = cell as? BreedPhotoCell.Placeholder {
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
    enum Section: Int, Hashable, CaseIterable {
        case top
        case middle
        case bottom
        
        var index: Int { rawValue }
        
        var numberOfItems: Int {
            switch self {
            case .top: return 1
            case .middle: return 6
            case .bottom: return 3
            }
        }
    }
    
    enum Row: Hashable {
        case error(String)
        case item(PhotoItem)
        case placeholder(UUID)
    }
}
