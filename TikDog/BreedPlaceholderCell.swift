//
//  BreedPlaceholderCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import Foundation
import UIKit

final class BreedPlaceholderCell: UITableViewCell {
    static let identifier = String(describing: BreedPlaceholderCell.self)
    let titlePlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = .opaqueSeparator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        titlePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titlePlaceholder)
        NSLayoutConstraint.activate([
            titlePlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: titlePlaceholder.trailingAnchor, constant: 16),
            titlePlaceholder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: titlePlaceholder.bottomAnchor, constant: 16),
            titlePlaceholder.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
