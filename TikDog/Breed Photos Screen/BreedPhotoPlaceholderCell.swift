//
//  BreedPhotoPlaceholderCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 24/04/2021.
//

import Foundation
import UIKit

final class BreedPhotoPlaceholderCell: UICollectionViewCell {
    static let identifier = String(describing: BreedPhotoPlaceholderCell.self)
    let shimmerView: ShimmerView = {
       let imageView = ShimmerView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        shimmerView.backgroundColor = .red
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        shimmerView.layoutIfNeeded()
//        shimmerView.startAnimating()
//    }
    
    func setUp() {
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shimmerView)
        NSLayoutConstraint.activate([
            shimmerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: shimmerView.trailingAnchor),
            shimmerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: shimmerView.bottomAnchor),
        ])
    }
}

class ShimmerView: UIView {
    let gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard gradientLayer.superlayer != layer else { return }
        
        addGradientLayer()
    }
    
    func addGradientLayer() {
        let darkColor = UIColor(white: 0.65, alpha: 1.0).cgColor
        let lightColor = UIColor(white: 0.75, alpha: 1.0).cgColor
        gradientLayer.borderWidth = 1
        gradientLayer.borderColor = darkColor
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
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
