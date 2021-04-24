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
    let breed: Breed
    let getBreedPhotos: () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
    let loadImage: (URL) -> AnyPublisher<UIImage?, Never>
    var subscription: AnyCancellable?
    
    init(
        breed: Breed,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>
    ) {
        self.breed = breed
        self.getBreedPhotos = getBreedPhotos
        self.loadImage = loadImage
        super.init(collectionViewLayout: Self.makeCollectionLayout())
        view.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(BreedPhotoCell.self, forCellWithReuseIdentifier: BreedPhotoCell.identifier)
        collectionView.dataSource = dataSource
        fetchBreedPhotos()
    }
    
    func fetchBreedPhotos() {
        dataSource.state = .loading
        subscription = getBreedPhotos()
            .receive(on: DispatchQueue.main)
            .sink { [weak dataSource] result in
                switch result {
                case let .success(response):
                    dataSource?.state = .loaded(response.photoURLs.map(Item.init))
                    
                case let .failure(error):
                    dataSource?.state = .failed(error)
                }
            }
    }
    
    static func makeCollectionLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            Section(sectionIndex).layout
        }
    }
}

struct Item {
    let url: URL
    var image: UIImage?
    
    init(url: URL) {
        self.url = url
        image = nil
    }
}
