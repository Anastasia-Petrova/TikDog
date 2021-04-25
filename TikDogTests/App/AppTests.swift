//
//  AppTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class AppTests: XCTestCase {
    func test_start_makesWindowKey_and_SetsRootViewContoller() {
        let app = App(service: .mockSuccess, imageLoader: .mock)
        let window = UIWindow(frame: .zero)
        XCTAssertFalse(window.isKeyWindow, "precondition")
        XCTAssertNil(window.rootViewController, "precondition")
        
        app.start(in: window)
        
        XCTAssertEqual(window.rootViewController, app.navigationController)
        XCTAssertTrue(window.isKeyWindow)
    }
    
    func test_start_setsBreedListViewController() throws {
        let app = App(service: .mockSuccess, imageLoader: .mock)
        XCTAssertTrue(app.navigationController.viewControllers.isEmpty, "precondition")

        app.start(in: UIWindow(frame: .zero))
        XCTAssertEqual(app.navigationController.viewControllers.count, 1)
        let vc = try XCTUnwrap(app.navigationController.viewControllers.first)
        XCTAssertTrue(vc is BreedListViewController)
    }
}
