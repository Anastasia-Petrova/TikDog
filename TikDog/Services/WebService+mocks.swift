//
//  WebService+mocks.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import UIKit

extension WebService {
    static let mockSuccess = WebService(
        getBreedsList: {
            Just(.success(BreedListResponse.mock))
                .eraseToAnyPublisher()
        },
        getBreedPhotos: { _ in
            Just(.success(PhotoPage.mock()))
                .eraseToAnyPublisher()
        }
    )
    
    static let mockFailure = WebService(
        getBreedsList: { genericError() },
        getBreedPhotos: { _ in genericError() }
    )
    
    private static func genericError<T>() -> AnyPublisher<Result<T, WebError>, Never> {
        Just(.failure(WebError.unknownError)).eraseToAnyPublisher()
    }
}

extension BreedListResponse {
    static var mock: BreedListResponse = {
        BreedListResponse(breeds: [
            Breed(identifier: "affenpinscher"),
            Breed(identifier: "african"),
            Breed(identifier: "airedale"),
            Breed(identifier: "akita"),
            Breed(identifier: "appenzeller"),
            Breed(identifier: "australian/shepherd", name: "Australian Shepherd")
        ])
    }()
}

extension PhotoPage {
    static func mock(with image: UIImage? = nil) -> PhotoPage {
        PhotoPage(
            topItem: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_13742.jpg")!, image: image),
            middleSection: [
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3059.jpg")!, image: image),
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3075.jpg")!, image: image),
                
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_357.jpg")!, image: image),
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3620.jpg")!, image: image),
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3793.jpg")!, image: image),
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3858.jpg")!, image: image),
            ],
            bottomSection: [
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_5150.jpg")!, image: image),
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_5345.jpg")!, image: image),
                .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_8315.jpg")!, image: image)
            ])
    }
}
