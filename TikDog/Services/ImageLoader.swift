//
//  ImageLoader.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import Foundation
import UIKit

struct ImageLoader {
    let load: (URL) -> AnyPublisher<UIImage?, Never>
}

extension ImageLoader {
    static let live = ImageLoader { url in
        let imageLoadingQueue = OperationQueue()
        imageLoadingQueue.maxConcurrentOperationCount = 3
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .subscribe(on: imageLoadingQueue)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

extension ImageLoader {
    static let mock = ImageLoader { _ in
        Just(UIImage(named: "dog")).eraseToAnyPublisher()
    }
}
