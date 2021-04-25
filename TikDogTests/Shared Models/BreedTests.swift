//
//  BreedTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class BreedTests: XCTestCase {
    func test_init_withDefaultSubBreed() {
        let breed = Breed(identifier: "pug")
        XCTAssertEqual(breed.name, "Pug")
        XCTAssertEqual(breed.identifier, "pug")
    }
    
    func test_init() {
        let breed = Breed(identifier: "australian/shepherd", name: "Australian Shepherd")
        XCTAssertEqual(breed.name, "Australian Shepherd")
        XCTAssertEqual(breed.identifier, "australian/shepherd")
    }
}
