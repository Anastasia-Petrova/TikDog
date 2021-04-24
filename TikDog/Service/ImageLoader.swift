//
//  ImageLoader.swift
//  TikDog
//
//  Created by Anastasia Petrova on 24/04/2021.
//

import Combine
import Foundation
import UIKit

struct ImageLoader {
    let load: (URL) -> AnyPublisher<UIImage?, Never>
}

extension ImageLoader {
    static let live = ImageLoader { url in
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

extension ImageLoader {
    static let mock = ImageLoader { _ in
        Just(UIImage(named: "avatar")).eraseToAnyPublisher()
    }
}
