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
    
    var didTapRetryButton: (() -> Void)? {
        get {
            errorView.didTapRetryButton
        }
        set {
            errorView.didTapRetryButton = newValue
        }
    }
    
    let errorView = ErrorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        contentView.embedSubview(errorView)
    }
    
    func setMessage(_ text: String) {
        errorView.setMessage(text)
    }
}
