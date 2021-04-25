//
//  BreedPhotoCellSnapshotTests.swift
//  TikDogSnapshotTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import SnapshotTesting
@testable import TikDog
import XCTest

//------- RUN SNAPSHOT TESTS ON iPhone SE (2nd generation) 14.4 -------

final class BreedPhotoCellSnapshotTests: XCTestCase {
    func test() {
        let cell = BreedCell()
        cell.setBreed(Breed(name: "pug"))
        cell.backgroundColor = .white
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 56))
        assertSnapshot(matching: cell, as: .image)
    }
}
