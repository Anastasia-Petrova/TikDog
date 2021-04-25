//
//  BreedCellTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//
@testable import TikDog
import XCTest

final class BreedCellTests: XCTestCase {
    func test_setBreed_setsTitle() {
        let cell = BreedCell()
        XCTAssertNil(cell.title.text, "precondition")
        cell.setBreed(Breed(name: "pug"))
        
        XCTAssertEqual(cell.title.text, "Pug")
    }
}
