//
//  BreedPhotosViewControllerSnapshotTests.swift
//  TikDogSnapshotTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import SnapshotTesting
@testable import TikDog
import XCTest

//------- RUN SNAPSHOT TESTS ON iPhone SE (2nd generation) 14.4 -------

final class BreedPhotosViewControllerSnapshotTests: XCTestCase {
    func test_loading() {
        let vc = BreedPhotosViewController(
            breedName: "Pug",
            breedPhotosPublisher: { WebService.mockSuccess.getBreedPhotos(Breed(name: "pug")) },
            loadImage: ImageLoader.mock.load
        )
        vc.loadViewIfNeeded()
        vc.dataSource.state = .loading
        vc.collectionView.reloadData()
        assertSnapshot(matching: vc, as: .image)
    }
    
    func test_loaded() {
        let vc = BreedPhotosViewController(
            breedName: "Pug",
            breedPhotosPublisher: { WebService.mockSuccess.getBreedPhotos(Breed(name: "pug")) },
            loadImage: ImageLoader.mock.load
        )
        vc.loadViewIfNeeded()
        let image = UIImage(named: "dog", in: Bundle(for: Self.self), with: nil)
        vc.dataSource.state = .loaded(PhotoPage.mock(with: image))
        vc.collectionView.reloadData()
        assertSnapshot(matching: vc, as: .image)
    }
    
    func test_failed() {
        let vc = BreedPhotosViewController(
            breedName: "Pug",
            breedPhotosPublisher: { WebService.mockSuccess.getBreedPhotos(Breed(name: "pug")) },
            loadImage: ImageLoader.mock.load
        )
        vc.loadViewIfNeeded()
        vc.dataSource.state = .failed(WebError(message: "Bad bard error", code: 400))
        vc.collectionView.reloadData()
        assertSnapshot(matching: vc, as: .image)
    }
}


