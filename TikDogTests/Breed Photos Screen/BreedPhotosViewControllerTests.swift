//
//  BreedPhotosViewControllerTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class BreedPhotosViewControllerTests: XCTestCase {
    func test_viewDidLoad_setsDataSource() throws {
        let vc = BreedPhotosViewController(
            breedName: "Pug",
            breedPhotosPublisher: { WebService.mockSuccess.getBreedPhotos(Breed(name: "pug")) },
            loadImage: ImageLoader.mock.load
        )
        vc.loadViewIfNeeded()
        let tableDataSource = try XCTUnwrap(vc.collectionView.dataSource as? BreedPhotosDataSource)
        let dataSource = try XCTUnwrap(vc.dataSource as? BreedPhotosDataSource)
        
        XCTAssertEqual(tableDataSource, dataSource)
    }
    
    func test_viewDidLoad_callsFetch() throws {
        let vc = BreedPhotosViewController(
            breedName: "Pug",
            breedPhotosPublisher: { WebService.mockSuccess.getBreedPhotos(Breed(name: "pug")) },
            loadImage: ImageLoader.mock.load
        )
        let spy = SpyCollectionDataSource()
        vc.dataSource = spy
        vc.loadViewIfNeeded()

        XCTAssertEqual(spy.fetchCallCount, 1)
    }
    
    func test_setImage_callsSetImage_onDataSource() throws {
        let vc = BreedPhotosViewController(
            breedName: "Pug",
            breedPhotosPublisher: { WebService.mockSuccess.getBreedPhotos(Breed(name: "pug")) },
            loadImage: ImageLoader.mock.load
        )
        let spy = SpyCollectionDataSource()
        vc.dataSource = spy
        
        let image = UIImage()
        let indexPath = IndexPath(row: 0, section: 0)
        vc.setImage(image, indexPath: indexPath)
        XCTAssertEqual(spy.image, image)
        XCTAssertEqual(spy.indexPath, indexPath)
    }
}

private final class SpyCollectionDataSource: NSObject, CollectionDataSource {
    var state: Loadable<PhotoPage> = .loading
    
    var image: UIImage?
    var indexPath: IndexPath?
    
    func setImage(_ image: UIImage, indexPath: IndexPath) {
        self.image = image
        self.indexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 0 }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
    
    var fetchCallCount: Int = 0

    func fetch() {
        fetchCallCount += 1
    }
}
