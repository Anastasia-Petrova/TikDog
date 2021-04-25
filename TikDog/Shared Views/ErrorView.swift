//
//  ErrorView.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import UIKit

final class ErrorView: UIView {
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
    
    let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        let stackView = UIStackView(arrangedSubviews: [title, retryButton])
        stackView.axis = .vertical
        embedSubview(stackView, offset: 16)
    }
    
    func setMessage(_ text: String) {
        title.text = text
    }
}
