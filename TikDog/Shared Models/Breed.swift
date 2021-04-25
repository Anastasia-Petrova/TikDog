//
//  Breed.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation

struct Breed: Hashable {
    let identifier: String
    let name: String
}

extension Breed {
    init(identifier: String) {
        self.identifier = identifier
        self.name = identifier.capitalized
    }
}
