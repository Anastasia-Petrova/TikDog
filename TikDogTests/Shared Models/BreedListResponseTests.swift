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
            Breed(identifier: "affenpinscher", name: "Affenpinscher"),
            Breed(identifier: "african", name: "African"),
            Breed(identifier: "airedale", name: "Airedale"),
            Breed(identifier: "akita", name: "Akita"),
            Breed(identifier: "appenzeller", name: "Appenzeller"),
            Breed(identifier: "australian/shepherd", name: "Shepherd Australian"),
            Breed(identifier: "bulldog/boston", name: "Boston Bulldog"),
            Breed(identifier: "bulldog/english", name: "English Bulldog"),
            Breed(identifier: "bulldog/french", name: "French Bulldog"),
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

