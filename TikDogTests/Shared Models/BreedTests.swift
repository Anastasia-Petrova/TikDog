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
        let breed = Breed(name: "pug")
        XCTAssertEqual(breed.name, "Pug")
        XCTAssertTrue(breed.subBreeds.isEmpty)
    }
    
    func test_init_capitalizesName() {
        let breed = Breed(name: "pug", subBreeds: [Breed(name: "sub pug")])
        XCTAssertEqual(breed.name, "Pug")
        XCTAssertEqual(breed.subBreeds, [Breed(name: "sub pug")])
    }
}
