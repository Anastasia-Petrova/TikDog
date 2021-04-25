//
//  BreedCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import Foundation
import UIKit

final class BreedCell: UITableViewCell {
    static let identifier = String(describing: BreedCell.self)
    private static let textStyle = UIFont.TextStyle.title3
    private static let offset: CGFloat = 16.0
    
    let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: BreedCell.textStyle)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        contentView.embedSubview(title, offset: Self.offset)
    }
    
    func setBreed(_ breed: Breed) {
        title.text = breed.name
    }
}

extension BreedCell {
    final class Placeholder: UITableViewCell {
        static let identifier = String(describing: Placeholder.self)
        let shimmerView = ShimmerView(borderWidth: 0, isDiagonal: false)
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setUp()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func calculateShimmerHeight() -> CGFloat {
            let label = UILabel()
            label.numberOfLines = 0
            label.text = "Hello, World!"
            label.font = .preferredFont(forTextStyle: BreedCell.textStyle)
            label.sizeToFit()
            return label.bounds.height
        }
        
        func setUp() {
            shimmerView.layer.cornerRadius = 4.0
            shimmerView.layer.masksToBounds = true
            contentView.embedSubview(shimmerView, offset: BreedCell.offset)
            let heightConstraint = shimmerView.heightAnchor.constraint(equalToConstant: calculateShimmerHeight())
            // UIView-Encapsulated-Layout-Height keeps breaking our height constraint, because it calculates
            // it's encapsulated height with a fraction of a point e.g (56.5).
            // No reason in fighting the framework, so we just yield to it with a lower priority.
            heightConstraint.priority = .defaultHigh
            NSLayoutConstraint.activate([heightConstraint])
        }
    }
}
