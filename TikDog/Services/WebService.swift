//
//  DogAPIService.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import Foundation

struct WebService {
    var getBreedsList: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    var getBreedPhotos: (Breed) -> AnyPublisher<Result<Photos, WebError>, Never>
}

extension WebService {
    static func live(baseURL: URL) -> WebService {
        WebService(
            getBreedsList: {
                get(request: Endpoint.breedList.getRequest(for: baseURL))
            },
            getBreedPhotos: { breed in
                get(request: Endpoint.breedPhotos(breedName: breed.name).getRequest(for: baseURL))
            }
        )
    }
}

extension WebService {
    static func get<T: Decodable>(
        request: URLRequest,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<Result<T, WebError>, Never> {
        session
            .dataTaskPublisher(for: request)
            .delay(for: 4, scheduler: DispatchQueue.main)
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

struct WebError: Decodable, Swift.Error {
    let message: String
    let code: Int
}

enum Endpoint {
    case breedList
    case breedPhotos(breedName: String)
    
    var stringValue: String {
        switch self {
        case .breedList:
            return "breeds/list/all"
            
        case let .breedPhotos(breedName):
            return "/breed/\(breedName)/images/random/10"
        }
    }
    
    func getRequest(for baseURL: URL) -> URLRequest {
        var r = URLRequest(url: baseURL.appendingPathComponent(stringValue))
        r.timeoutInterval = 5
        return r
    }
}