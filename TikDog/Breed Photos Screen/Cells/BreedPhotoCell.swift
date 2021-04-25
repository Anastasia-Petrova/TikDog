//
//  BreedPhotoCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation
import UIKit

final class BreedPhotoCell: UICollectionViewCell {
    static let identifier = String(describing: BreedPhotoCell.self)
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.embedSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BreedPhotoCell {
    final class Placeholder: UICollectionViewCell {
        static let identifier = String(describing: Placeholder.self)
        let shimmerView = ShimmerView(borderWidth: 1, isDiagonal: true)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setUp()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setUp() {
            contentView.embedSubview(shimmerView)
        }
    }
}

extension UIView {
    @discardableResult
    func embedSubview(_ subview: UIView, offset: CGFloat = 0.0) -> [NSLayoutConstraint] {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        let constraints = [
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: offset),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: offset),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: offset),
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}
