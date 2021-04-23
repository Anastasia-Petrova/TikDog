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
    let getBreedPhotos: () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
}

extension DogAPIService {
    static func live(baseURL: URL) -> DogAPIService {
        DogAPIService(
            getBreedsList: {
                get(request: Endpoint.breedList.getRequest(for: baseURL))
            },
            getBreedPhotos: {
                get(request: Endpoint.breedPhotos(breedName: "String", numberOfPhotos: 10).getRequest(for: baseURL))
            }
        )
    }
    
    static let mock = DogAPIService(
        getBreedsList: {
            Just(.success(BreedListResponse.mock))
                .eraseToAnyPublisher()
        },
        getBreedPhotos: {
            Just(.failure(WebError(
                message: "Something went wrong. Try again.",
                code: 400
            ))).eraseToAnyPublisher()
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

struct WebError: Decodable, Swift.Error {
    let message: String
    let code: Int
}
