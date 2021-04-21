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
    let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
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
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
        ])
    }
    
    func setBreed(_ breed: Breed) {
        title.text = breed.name
    }
}
