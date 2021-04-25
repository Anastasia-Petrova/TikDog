//
//  WebService+mocks.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import Foundation

extension WebService {
    static let mockSuccess = WebService(
        getBreedsList: {
            Just(.success(BreedListResponse.mock))
                .eraseToAnyPublisher()
        },
        getBreedPhotos: { _ in
            Just(.success(PhotosPage.mock))
                .eraseToAnyPublisher()
        }
    )
    
    static let mockFailure = WebService(
        getBreedsList: { genericError() },
        getBreedPhotos: { _ in genericError() }
    )
    
    private static func genericError<T>() -> AnyPublisher<Result<T, WebError>, Never> {
        Just(.failure(WebError(
            message: "Something went wrong. Try again.",
            code: 400
        ))).eraseToAnyPublisher()
    }
}

extension BreedListResponse {
    static var mock: BreedListResponse = {
        BreedListResponse(breeds: [
            Breed(name: "affenpinscher"),
            Breed(name: "african"),
            Breed(name: "airedale"),
            Breed(name: "akita"),
            Breed(name: "appenzeller"),
            Breed(name: "australian", subBreeds: [Breed(name: "shepherd")])
        ])
    }()
}

extension PhotosPage {
    static var mock: PhotosPage = {
        PhotosPage(
            topSection: .init(item: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_13742.jpg")!)),
            middleSection: .init(
                leadingColumn: .init(
                    top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3059.jpg")!),
                    bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3075.jpg")!)
                ),
                centralColumn: .init(
                    top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_357.jpg")!),
                    bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3620.jpg")!)
                ),
                trailingColumn: .init(
                    top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3793.jpg")!),
                    bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3858.jpg")!)
                )
            ),
            bottomSection: .init(
                leadingItem: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_5150.jpg")!),
                trailingColumn: .init(
                    top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_5345.jpg")!),
                    bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_8315.jpg")!)
                )
            )
        )
    }()
}

extension BreedPhotosResponse {
    static var mock: BreedPhotosResponse = {
        BreedPhotosResponse(
            page: PhotosPage(
                topSection: .init(item: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_13742.jpg")!)),
                middleSection: .init(
                    leadingColumn: .init(
                        top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3059.jpg")!),
                        bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3075.jpg")!)
                    ),
                    centralColumn: .init(
                        top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_357.jpg")!),
                        bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3620.jpg")!)
                    ),
                    trailingColumn: .init(
                        top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3793.jpg")!),
                        bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_3858.jpg")!)
                    )
                ),
                bottomSection: .init(
                    leadingItem: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_5150.jpg")!),
                    trailingColumn: .init(
                        top: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_5345.jpg")!),
                        bottom: .init(url: URL(string: "https://images.dog.ceo/breeds/hound-afghan/n02088094_8315.jpg")!)
                    )
                )
            )
        )
    }()
}
