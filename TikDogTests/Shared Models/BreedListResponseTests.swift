//
//  BreedListResponseTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class BreedListResponseTests: XCTestCase {
    func test_decoding() throws {
        let expected = BreedListResponse(breeds: [
            Breed(name: "affenpinscher", subBreeds: []),
            Breed(name: "african", subBreeds: []),
            Breed(name: "airedale", subBreeds: []),
            Breed(name: "akita", subBreeds: []),
            Breed(name: "appenzeller", subBreeds: []),
            Breed(name: "australian", subBreeds: [Breed(name: "shepherd")]),
            Breed(name: "bulldog", subBreeds: [
                Breed(name: "boston"),
                Breed(name: "english"),
                Breed(name: "french")
            ]),
        ])
        let jsonData = """
        {
            "message": {
                "affenpinscher": [],
                "african": [],
                "airedale": [],
                "akita": [],
                "appenzeller": [],
                "australian": [
                    "shepherd"
                ],
                "bulldog": [
                    "boston",
                    "english",
                    "french"
                ],
            },
            "status": "success"
        }
        """.data(using: .utf8)!
        
        let actual = try JSONDecoder().decode(BreedListResponse.self, from: jsonData)

        XCTAssertEqual(actual, expected)
    }
}
