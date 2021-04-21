//
//  DogAPIService.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import Foundation

enum Endpoint {
    case breedList
    case breedPhotos(breedName: String, numberOfPhotos: UInt)
    
    var stringValue: String {
        switch self {
        case .breedList:
            return "breeds/list/all"
            
        case let .breedPhotos(breedName, numberOfPhotos):
            return "/breed/\(breedName)/images/random/\(numberOfPhotos)"
        }
    }
}

struct DogAPIService {
    struct Error: Decodable, Swift.Error {
        let message: String
        let code: Int
    }

    let baseURL: URL
    
    func getRequest(for endpoint: Endpoint) -> URLRequest {
        URLRequest(url: baseURL.appendingPathComponent(endpoint.stringValue))
    }
    
    static func get<T: Decodable>(
        request: URLRequest,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, Error> {
        session
            .dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw Error(
                        message: "Something went wrong. Try again.",
                        code: 0
                    )
                }
                
                switch response.statusCode {
                case 200:
                    return output.data
                    
                case 400...599:
                    throw try decoder.decode(Error.self, from: output.data)
                    
                default:
                    throw Error(
                        message: "Something went wrong. Try again.",
                        code: response.statusCode
                    )
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError(Error.init)
            .eraseToAnyPublisher()
    }
}

extension DogAPIService.Error {
    init(_ error: Swift.Error) {
        self.init(message: error.localizedDescription, code: 0)
    }
}
