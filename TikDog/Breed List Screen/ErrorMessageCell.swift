//
//  ErrorMessageCell.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import Foundation
import UIKit

final class ErrorMessageCell: UITableViewCell {
    static let identifier = String(describing: ErrorMessageCell.self)
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        let stackView = UIStackView(arrangedSubviews: [message, retryButton])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
        ])
    }
    
    func setMessage(_ text: String) {
        message.text = text
    }
}
