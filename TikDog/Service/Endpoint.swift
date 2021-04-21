//
//  Endpoint.swift
//  TikDog
//
//  Created by Anastasia Petrova on 22/04/2021.
//

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
    
    func getRequest(for baseURL: URL) -> URLRequest {
        var r = URLRequest(url: baseURL.appendingPathComponent(stringValue))
        r.timeoutInterval = 5
        return r
    }
}
