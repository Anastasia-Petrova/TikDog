//
//  Breed.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation

struct Breed: Hashable {
    let name: String
    let subBreeds: [Breed]
    
    init(name: String, subBreeds: [Breed]) {
        self.name = name.capitalized
        self.subBreeds = subBreeds
    }
}

extension Breed {
    init(name: String) {
        self.name = name.capitalized
        subBreeds = []
    }
}
