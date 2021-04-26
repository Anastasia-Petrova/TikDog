//
//  BreedPhotosDataSourceTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
@testable import TikDog
import XCTest

final class BreedPhotosDataSourceTests: XCTestCase {
    typealias Row = BreedPhotosViewController.Row
    typealias Section = BreedPhotosViewController.Section
    
    func test_fetch_setsStateToLoading_andMakesRequest() {
        var counter = 0
        let dataSource = makeDataSource(
            initialState: .failed(WebError(message: "")),
            getBreedPhotos: {
                counter += 1
                return WebService.mockSuccess.getBreedPhotos(Breed(identifier: "pug"))
            }
        )
        XCTAssertNil(dataSource.photosRequestSubscription, "precondition")
        dataSource.fetch()
        
        XCTAssertEqual(dataSource.state, .loading)
        XCTAssertEqual(counter, 1)
        XCTAssertNotNil(dataSource.photosRequestSubscription)
    }
    
    func test_updateScrollingState() {
        let dataSource = makeDataSource()
        dataSource.state = .failed(WebError(message: ""))
        dataSource.updateScrollingState()
        XCTAssertFalse(dataSource.collectionView.isScrollEnabled)
        
        dataSource.state = .loading
        dataSource.updateScrollingState()
        XCTAssertFalse(dataSource.collectionView.isScrollEnabled)
        
        dataSource.state = .loaded(PhotoPage.mock())
        dataSource.updateScrollingState()
        XCTAssertTrue(dataSource.collectionView.isScrollEnabled)
    }
    
    func test_setImage() {
        let dataSource = makeDataSource()
        dataSource.state = .loaded(PhotoPage.mock())
        let image = UIImage()
        
        dataSource.setImage(image, indexPath: IndexPath(row: 0, section: 0))
        
        guard case let .loaded(actualPhotos) = dataSource.state else {
            XCTFail("expected loaded")
            return
        }
        XCTAssertEqual(actualPhotos.topItem.image, image)
    }
    
    func test_getSnapshot_whenLoading() {
        let str = "E621E1F8-C36C-495A-93FC-0C247A3E6E5"
        var counter: NSNumber = 0
        let mockUUID: () -> UUID = {
            let uuidString = str + "\(counter.intValue)"
            counter = NSNumber(value: counter.intValue + 1)
            return UUID(uuidString: uuidString)!
        }
        BreedPhotosDataSource.UUID = mockUUID

        let snapshot = BreedPhotosDataSource.getSnapshot(for: .loading)

        counter = 0
        XCTAssertEqual(snapshot.sectionIdentifiers, Section.allCases)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .top), [Row.placeholder(mockUUID())])
        XCTAssertEqual(
            snapshot.itemIdentifiers(inSection: .middle),
            [
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID())
            ]
        )
        XCTAssertEqual(
            snapshot.itemIdentifiers(inSection: .bottom),
            [
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID()),
                Row.placeholder(mockUUID())
            ]
        )
        BreedPhotosDataSource.UUID = UUID.init
    }
    
    func test_getSnapshot_whenLoaded() {
        let snapshot = BreedPhotosDataSource.getSnapshot(for: .loaded(PhotoPage.mock()))
        let mockPhotoPage = PhotoPage.mock()
        XCTAssertEqual(snapshot.sectionIdentifiers, Section.allCases)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .top), [Row.item(mockPhotoPage.topItem)])
        XCTAssertEqual(
            snapshot.itemIdentifiers(inSection: .middle),
            mockPhotoPage.middleSection.map(Row.item)
        )
        XCTAssertEqual(
            snapshot.itemIdentifiers(inSection: .bottom),
            mockPhotoPage.bottomSection.map(Row.item)
        )
    }
    
    func test_getSnapshot_whenFailed() {
        let snapshot = BreedPhotosDataSource.getSnapshot(for: .failed(WebError(message: "Bad error")))
        
        XCTAssertEqual(snapshot.sectionIdentifiers, [Section.top])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .top), [Row.error("Bad error")])
    }
    
    private func makeDataSource(
        initialState: Loadable<PhotoPage> = .loading,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<PhotoPage, WebError>, Never> = { WebService.mockSuccess.getBreedPhotos(Breed(identifier: "pug")) }
    ) -> BreedPhotosDataSource {
        BreedPhotosDataSource(
            collectionView: UICollectionView(frame: .zero, collectionViewLayout: BreedPhotosViewController.collectionLayout),
            getBreedPhotos: getBreedPhotos,
            loadImage: ImageLoader.mock.load,
            retryAction: { },
            setImage: { _, _ in }
        )
    }
}
