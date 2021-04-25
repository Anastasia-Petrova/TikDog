//
//  Loadable.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation

// Sum data type to represent exlusive UI states and make impossible state unrepresentable in type system.
enum Loadable<Content: Equatable>: Equatable {
    case failed(WebError)
    case loaded(Content)
    case loading
}
