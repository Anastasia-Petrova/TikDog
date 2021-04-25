//
//  DogAPIService.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import Foundation

struct DogAPIService {
    let getBreedsList: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    let getBreedPhotos: (Breed) -> AnyPublisher<Result<Page, WebError>, Never>
}

extension DogAPIService {
    static func live(baseURL: URL) -> DogAPIService {
        DogAPIService(
            getBreedsList: {
                get(request: Endpoint.breedList.getRequest(for: baseURL))
            },
            getBreedPhotos: { breed in
                get(request: Endpoint.breedPhotos(breedName: breed.name).getRequest(for: baseURL))
            }
        )
    }
    
    static let mock = DogAPIService(
        getBreedsList: {
            Just(.success(BreedListResponse.mock))
                .eraseToAnyPublisher()
        },
        getBreedPhotos: { _ in
            Future { fulfill in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    fulfill(.success(.success(Page.mock)))
//                }
            }.eraseToAnyPublisher()
//            Just(.success(BreedPhotosResponse.mock))
//                .eraseToAnyPublisher()
//            Just(.failure(WebError(
//                message: "Something went wrong. Try again.",
//                code: 400
//            ))).eraseToAnyPublisher()
        }
    )
}

extension DogAPIService {
    static func get<T: Decodable>(
        request: URLRequest,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<Result<T, WebError>, Never> {
        session
            .dataTaskPublisher(for: request)
//            .delay(for: 4, scheduler: DispatchQueue.main)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw WebError(
                        message: "Something went wrong. Try again.",
                        code: 0
                    )
                }
                
                switch response.statusCode {
                case 200:
                    return output.data
                    
                case 400...599:
                    throw try decoder.decode(WebError.self, from: output.data)
                    
                default:
                    throw WebError(
                        message: "Something went wrong. Try again.",
                        code: response.statusCode
                    )
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError(WebError.init)
            .map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
    
    
}

extension WebError {
    init(_ error: Swift.Error) {
        self.init(message: error.localizedDescription, code: 0)
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

extension Page {
    static var mock: Page = {
        Page(
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
            page: Page(
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

enum Loadable<Content> {
    case failed(WebError)
    case loaded(Content)
    case loading
}

struct WebError: Decodable, Swift.Error {
    let message: String
    let code: Int
}
