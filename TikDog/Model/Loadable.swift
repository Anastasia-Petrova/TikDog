//
//  Loadable.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation

enum Loadable<Content> {
    case failed(WebError)
    case loaded(Content)
    case loading
}
