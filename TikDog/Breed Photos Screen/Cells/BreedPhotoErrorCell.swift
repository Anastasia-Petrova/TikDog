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
    
    var didTapRetryButton: (() -> Void)? {
        get {
            errorView.didTapRetryButton
        }
        set {
            errorView.didTapRetryButton = newValue
        }
    }
    
    let errorView = ErrorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        errorView.backgroundColor = .white
        errorView.layer.cornerRadius = 10
        errorView.layer.masksToBounds = true
        contentView.embedSubview(errorView, offset: 40)
    }
    
    func setMessage(_ text: String) {
        errorView.setMessage(text)
    }
}
