//
//  BreedListResponse.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation

struct BreedListResponse: Equatable {
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
            .flatMap { mainIdentifier, subBreedIdentifiers -> [Breed] in
                if subBreedIdentifiers.isEmpty {
                    return [Breed(identifier: mainIdentifier, name: mainIdentifier.capitalized)]
                } else {
                    return subBreedIdentifiers.map{
                        Breed(
                            identifier: mainIdentifier + "/" + $0,
                            name: $0.capitalized + " " + mainIdentifier.capitalized
                        )
                    }
                }
            }
            .sorted { $0.identifier < $1.identifier}
    }
}
