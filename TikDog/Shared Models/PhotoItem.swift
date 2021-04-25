//
//  PhotoItem.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import UIKit

struct PhotoItem: Hashable {
    let url: URL
    var image: UIImage?
    
    init(url: URL) {
        self.url = url
        image = nil
    }
}
