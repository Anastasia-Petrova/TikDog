//
//  BreedPhotoErrorCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation
import UIKit

final class BreedPhotoErrorCell: UICollectionViewCell {
    static let identifier = String(describing: BreedPhotoErrorCell.self)
    
    lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtonAction), for: .touchUpInside)
        button.setTitle("Try again", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        return button
    }()
    
    var didTapRetryButton: (() -> Void)?
    
    @objc func retryButtonAction() {
        didTapRetryButton?()
    }
    
    let message: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        let stackView = UIStackView(arrangedSubviews: [message, retryButton])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
        contentView.embedSubview(stackView, offset: 40)
    }
    
    func setMessage(_ text: String) {
        message.text = text
    }
}
