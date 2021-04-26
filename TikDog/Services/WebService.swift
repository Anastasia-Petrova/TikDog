//
//  DogAPIService.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import Foundation

struct WebService {
    var getBreedsList: () -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    var getBreedPhotos: (Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never>
}

extension WebService {
    static func live(baseURL: URL) -> WebService {
        WebService(
            getBreedsList: {
                get(request: Endpoint.breedList.getRequest(for: baseURL))
            },
            getBreedPhotos: { breed in
                get(request: Endpoint.breedPhotos(breedIdentifier: breed.identifier).getRequest(for: baseURL))
            }
        )
    }
}

extension WebService {
    static func get<T: Decodable>(request: URLRequest) -> AnyPublisher<Result<T, WebError>, Never> {
        let decoder = JSONDecoder()
        return URLSession.shared
            .dataTaskPublisher(for: request)
//            Uncomment to experience shimmer effect. Use bad network conditioner otherwise.
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

struct WebError: Decodable, Swift.Error, Equatable {
    let message: String
    let code: Int
}

enum Endpoint {
    case breedList
    case breedPhotos(breedIdentifier: String)
    
    var stringValue: String {
        switch self {
        case .breedList:
            return "breeds/list/all"
            
        case let .breedPhotos(breedIdentifier):
            return "/breed/\(breedIdentifier)/images/random/10"
        }
    }
    
    func getRequest(for baseURL: URL) -> URLRequest {
        let request = URLRequest(url: baseURL.appendingPathComponent(stringValue))
//        Uncomment to get fast failures with bad network conditioner.
//        request.timeoutInterval = 5
        return request
    }
}
