//
//  Breed.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import Foundation

struct Breed: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let subBreeds: [Breed]
}

extension Breed {
    init(name: String) {
        self.name = name
        subBreeds = []
    }
}

struct BreedListResponse {
    let breeds: [Breed]
}

extension BreedListResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        breeds = try decoder
            .container(keyedBy: CodingKeys.self)
            .decode(Dictionary<String, [String]>.self, forKey: .message)
            .map { Breed(name: $0, subBreeds: $1.map(Breed.init)) }
            .sorted { $0.name < $1.name}
    }
}

struct BreedPhotosResponse: Decodable {
    let photoURLs: [URL]
    
    private enum CodingKeys: String, CodingKey {
        case photoURLs = "message"
    }
}
