//
//  WebServiceUnitTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 26/04/2021.
//

@testable import TikDog
import XCTest

final class WebServiceUnitTests: XCTestCase {
    func test_endpoint_breedList() {
        let baseURL = URL(string: "https://dog.ceo/api")!
        let actual = Endpoint.breedList.getRequest(for: baseURL)
        let expected = URLRequest(url: URL(string: "https://dog.ceo/api/breeds/list/all")!)
        XCTAssertEqual(actual, expected)
    }

    func test_endpoint_breedPhotos() {
        let baseURL = URL(string: "https://dog.ceo/api")!
        let actual = Endpoint.breedPhotos(breedIdentifier: "australian/shepherd").getRequest(for: baseURL)
        let expected = URLRequest(url: URL(string: "https://dog.ceo/api/breed/australian/shepherd/images/random/10")!)
        XCTAssertEqual(actual, expected)
    }
}
