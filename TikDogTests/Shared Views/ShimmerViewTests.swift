//
//  ShimmerViewTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class ShimmerViewTests: XCTestCase {
    func test_init() throws {
        let view = ShimmerView(borderWidth: 10, isDiagonal: true)
        XCTAssertEqual(view.borderWidth, 10)
        XCTAssertTrue(view.isDiagonal)
    }
    
    func test_init_defaults() throws {
        let view = ShimmerView()
        XCTAssertEqual(view.borderWidth, 0)
        XCTAssertFalse(view.isDiagonal)
    }

    func test_startAnimating_and_stopAnimating() throws {
        let view = ShimmerView()
        XCTAssertNil(view.gradientLayer.animationKeys(), "precondition")
        
        view.startAnimating()
        XCTAssertEqual(view.gradientLayer.animationKeys(), ["shimmering"])
        
        view.stopAnimating()
        XCTAssertNil(view.gradientLayer.animationKeys())
    }
    
    func test_makeShimmerAnimation() throws {
        let animation = ShimmerView.makeShimmerAnimation()
        
        let fromValue = try XCTUnwrap(animation.fromValue as? [Double])
        let toValue = try XCTUnwrap(animation.toValue as? [Double])
        XCTAssertEqual(fromValue, [-1.0, -0.5, 0.0])
        XCTAssertEqual(toValue, [1.0, 1.5, 2.0])
        XCTAssertEqual(animation.repeatCount, .infinity)
        XCTAssertEqual(animation.duration, 1.6)
    }
    
    func test_addGradientLayer() throws {
        let view = ShimmerView()
        view.addGradientLayer()
        
        let layer = view.gradientLayer
        let colors = try XCTUnwrap(layer.colors as? [CGColor])
        XCTAssertEqual(layer.borderWidth, view.borderWidth)
        XCTAssertEqual(layer.borderColor, view.darkColor)
        XCTAssertEqual(layer.frame, view.bounds)
        XCTAssertEqual(colors, [view.lightColor, view.darkColor, view.lightColor])
        XCTAssertEqual(layer.startPoint, CGPoint(x: 0.0, y: 1.0))
        XCTAssertEqual(layer.endPoint, CGPoint(x: 1.0, y: 1.0))
        XCTAssertEqual(layer.locations, [0.0, 0.5, 1.0])
    }
    
    func test_layoutSubviews_addsGradientLayer() {
        let view = ShimmerView()
        XCTAssertNotEqual(view.gradientLayer.superlayer, view.layer, "precondition")
        
        view.layoutSubviews()
        
        XCTAssertEqual(view.gradientLayer.superlayer, view.layer)
    }
}
