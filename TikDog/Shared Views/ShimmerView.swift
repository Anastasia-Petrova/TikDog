//
//  ShimmerView.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation
import UIKit

final class ShimmerView: UIView {
    let gradientLayer = CAGradientLayer()
    let borderWidth: CGFloat
    let isDiagonal: Bool
    
    init(borderWidth: CGFloat = 0, isDiagonal: Bool = false) {
        self.borderWidth = borderWidth
        self.isDiagonal = isDiagonal
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard gradientLayer.superlayer != layer else { return }
        
        addGradientLayer()
    }
    
    func addGradientLayer() {
        let darkColor = UIColor(white: 0.65, alpha: 1.0).cgColor
        let lightColor = UIColor(white: 0.75, alpha: 1.0).cgColor
        gradientLayer.borderWidth = borderWidth
        gradientLayer.borderColor = darkColor
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: isDiagonal ? 0.0 : 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [lightColor, darkColor, lightColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }
    
    func makeShimmerAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.6
        return animation
    }
    
    func startAnimating() {
        let animation = makeShimmerAnimation()
        gradientLayer.add(animation, forKey: animation.keyPath)
    }

    func stopAnimating() {
        gradientLayer.removeAllAnimations()
    }
}
