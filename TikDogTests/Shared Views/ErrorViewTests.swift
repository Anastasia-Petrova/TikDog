//
//  ErrorViewTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class ErrorViewTests: XCTestCase {
    func test_retryButton_action() {
        let view = ErrorView()
        var counter = 0
        view.didTapRetryButton = {
            counter += 1
        }
        
        view.retryButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(counter, 1)
    }
}
