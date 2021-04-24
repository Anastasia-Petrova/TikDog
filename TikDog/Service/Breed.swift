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
    let page: Page
    
    private enum CodingKeys: String, CodingKey {
        case page = "message"
    }
}

////Type safe array of ten elements.
//struct Ten<Element: Decodable>: Decodable {
//    let one: Element
//    let two: Element
//    let three: Element
//    let four: Element
//    let five: Element
//    let six: Element
//    let seven: Element
//    let eight: Element
//    let nine: Element
//    let ten: Element
//
//    init(from decoder: Decoder) throws {
//        var container = try decoder.unkeyedContainer()
//        let arrayValue = try container.decode([Element].self)
//        guard arrayValue.count == 10 else {
//            throw DecodingError.typeMismatch(
//                Ten<Element>.self,
//                DecodingError.Context(codingPath: [], debugDescription: "Expected to get array of ten elements")
//            )
//        }
//
//        one = arrayValue[0]
//        two = arrayValue[1]
//        three = arrayValue[2]
//        four = arrayValue[3]
//        five = arrayValue[4]
//        six = arrayValue[5]
//        seven = arrayValue[6]
//        eight = arrayValue[7]
//        nine = arrayValue[8]
//        ten = arrayValue[9]
//    }
//
//    var arrayValue: [Element] {
//        [one, two, three, four, five, six, seven, eight, nine, ten]
//    }
//}
