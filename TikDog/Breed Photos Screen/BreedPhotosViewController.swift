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
        getBreedPhotos: getBreedPhotos,
        loadImage: loadImage,
        retryAction: { [weak self] in self?.fetchBreedPhotos() },
        setImage: { [weak self] in self?.setImage($0, indexPath: $1) }
    )

    let getBreedPhotos: () -> AnyPublisher<Result<Page, WebError>, Never>
    let loadImage: (URL) -> AnyPublisher<UIImage?, Never>
    
    init(
        getBreedPhotos: @escaping () -> AnyPublisher<Result<Page, WebError>, Never>,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>
    ) {
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
