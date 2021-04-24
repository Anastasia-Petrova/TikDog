//
//  BreedPhotoCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 24/04/2021.
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
        contentView.backgroundColor = .black
        contentView.layer.masksToBounds = true
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
    }
}
