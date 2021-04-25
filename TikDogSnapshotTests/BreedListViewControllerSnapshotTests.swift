//
//  BreedListViewControllerSnapshotTests.swift
//  TikDogSnapshotTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import SnapshotTesting
@testable import TikDog
import XCTest

//------- RUN SNAPSHOT TESTS ON iPhone SE (2nd generation) 14.4 -------

final class BreedListViewControllerSnapshotTests: XCTestCase {
    func test_loaded() {
        let vc = BreedListViewController(
            breedListPublisher: WebService.mockSuccess.getBreedsList,
            didSelectBreed: { _ in }
        )
        vc.loadViewIfNeeded()
        vc.dataSource.state = .loaded(BreedListResponse.mock.breeds)
        vc.view.frame = CGRect(origin: .zero, size: CGSize(width: 375, height: 667))
        assertSnapshot(matching: vc, as: .image)
    }
    
    func test_loading() {
        let vc = BreedListViewController(
            breedListPublisher: WebService.mockSuccess.getBreedsList,
            didSelectBreed: { _ in }
        )
        vc.loadViewIfNeeded()
        vc.dataSource.state = .loading
        vc.view.frame = CGRect(origin: .zero, size: CGSize(width: 375, height: 667))
        assertSnapshot(matching: vc, as: .image)
    }
    
    func test_failed() {
        let vc = BreedListViewController(
            breedListPublisher: WebService.mockSuccess.getBreedsList,
            didSelectBreed: { _ in }
        )
        vc.loadViewIfNeeded()
        vc.dataSource.state = .failed(WebError(message: "Bad bard error", code: 400))
        vc.view.frame = CGRect(origin: .zero, size: CGSize(width: 375, height: 667))
        assertSnapshot(matching: vc, as: .image)
    }
}
