//
//  BreedPhotosViewControllerSnapshotTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import SnapshotTesting
@testable import TikDog
import XCTest

//------- RUN SNAPSHOT TESTS ON iPhone SE (2nd generation) 14.4 -------

final class BreedPhotoErrorCellSnapshotTests: XCTestCase {
    func test() {
        let cell = BreedPhotoErrorCell()
        cell.setMessage("Bad Bad Error Bad Bad Error")
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 200))
        assertSnapshot(matching: cell, as: .image)
    }
}
