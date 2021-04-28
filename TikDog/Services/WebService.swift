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
                    throw WebError.unknownError
                }
                
                switch response.statusCode {
                case 200:
                    return output.data
                    
                case 400...599:
                    throw try decoder.decode(WebError.self, from: output.data)
                    
                default:
                    throw WebError.unknownError
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
        self.init(message: error.localizedDescription)
    }
    
    static let unknownError = WebError(message: "Something went wrong. Try again.")
}

struct WebError: Decodable, Swift.Error, Equatable {
    let message: String
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

protocol WebServiceProtocol {
    func getBreedsList() -> AnyPublisher<Result<BreedListResponse, WebError>, Never>
    func getBreedPhotos(breed: Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never>
}

struct WebServiceLive: WebServiceProtocol {
    let baseURL: URL
    
    func getBreedsList() -> AnyPublisher<Result<BreedListResponse, WebError>, Never> {
        WebService.get(request: Endpoint.breedList.getRequest(for: baseURL))
    }
    
    func getBreedPhotos(breed: Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never> {
        WebService.get(request: Endpoint.breedPhotos(breedIdentifier: breed.identifier).getRequest(for: baseURL))
    }
}

struct WebServiceMockSuccess: WebServiceProtocol {
    func getBreedsList() -> AnyPublisher<Result<BreedListResponse, WebError>, Never> {
        Just(.success(BreedListResponse.mock))
            .eraseToAnyPublisher()
    }
    
    func getBreedPhotos(breed: Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never> {
        Just(.success(PhotoPage.mock()))
            .eraseToAnyPublisher()
    }
}

struct WebServiceMockFailure: WebServiceProtocol {
    func getBreedsList() -> AnyPublisher<Result<BreedListResponse, WebError>, Never> {
        Just(.failure(WebError.unknownError))
            .eraseToAnyPublisher()
    }
    
    func getBreedPhotos(breed: Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never> {
        Just(.failure(WebError.unknownError))
            .eraseToAnyPublisher()
    }
}

struct WebServiceMockSuccessFailure1: WebServiceProtocol {
    func getBreedsList() -> AnyPublisher<Result<BreedListResponse, WebError>, Never> {
        Just(.success(BreedListResponse.mock))
            .eraseToAnyPublisher()
    }
    
    func getBreedPhotos(breed: Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never> {
        Just(.failure(WebError.unknownError))
            .eraseToAnyPublisher()
    }
}

struct WebServiceMockSuccessFailure2: WebServiceProtocol {
    func getBreedsList() -> AnyPublisher<Result<BreedListResponse, WebError>, Never> {
        Just(.failure(WebError.unknownError))
            .eraseToAnyPublisher()
    }
    
    func getBreedPhotos(breed: Breed) -> AnyPublisher<Result<PhotoPage, WebError>, Never> {
        Just(.success(PhotoPage.mock()))
            .eraseToAnyPublisher()
    }
}

class VC {
    let service: WebServiceProtocol
    
    init(service: WebServiceProtocol) {
        self.service = service
    }
}


let mockSuccess = WebServiceMockSuccess()
let mockFailure = WebServiceMockFailure()

let vc = VC(service: mockSuccess)
