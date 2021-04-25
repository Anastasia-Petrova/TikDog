//
//  PhotosPage.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import Foundation
import UIKit

struct PhotosPage {
    var topSection: Section.Top
    var middleSection: Section.Middle?
    var bottomSection: Section.Bottom?
}

extension PhotosPage {
    enum Section: Hashable {
        case top(Top)
        case middle(Middle)
        case bottom(Bottom)
    }
}

extension PhotosPage.Section {
    struct Column: Hashable {
        var top: Item
        var bottom: Item?
        
        var items: [Item] {
            [top, bottom].compactMap { $0 }
        }
    }
}

extension PhotosPage.Section {
    struct Top: Hashable {
        static let numberOfItems = 1
        
        var item: Item
    }
}

extension PhotosPage.Section {
    struct Middle: Hashable {
        static let numberOfItems: Int = 6
        
        var leadingColumn: Column
        var centralColumn: Column?
        var trailingColumn: Column?
        
        var items: [Item] {
            leadingColumn.items
                + (centralColumn?.items ?? [])
                + (trailingColumn?.items ?? [])
        }
    }
}

extension PhotosPage.Section {
    struct Bottom: Hashable {
        static let numberOfItems: Int = 3
        
        var leadingItem: Item
        var trailingColumn: Column?
        
        var items: [Item] {
            [leadingItem] + (trailingColumn?.items ?? [])
        }
    }
}

extension PhotosPage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urls = try container.decode([URL].self, forKey: .message)
        
        guard urls.count > 0 else {
            throw DecodingError.typeMismatch(
                PhotosPage.self,
                DecodingError.Context(codingPath: [], debugDescription: "Expected to get at least one URL")
            )
        }
        topSection = Section.Top(item: Item(url: urls[0]))
        middleSection = urls[maybe: 1].map { url in
            Section.Middle(
                leadingColumn: Section.Column(
                    top: Item(url: url),
                    bottom: urls[maybe: 2].map(Item.init)
                ),
                centralColumn: urls[maybe: 3].map { url in
                    Section.Column(
                        top: Item(url: url),
                        bottom: urls[maybe: 4].map(Item.init)
                    )
                },
                trailingColumn: urls[maybe: 5].map { url in
                    Section.Column(
                        top: Item(url: url),
                        bottom: urls[maybe: 6].map(Item.init)
                    )
                }
            )
        }
        bottomSection = urls[maybe: 7].map { url in
            Section.Bottom(
                leadingItem: Item(url: url),
                trailingColumn: urls[maybe: 8].map { url in
                    Section.Column(
                        top: Item(url: url),
                        bottom: urls[maybe: 9].map(Item.init)
                    )
                }
            )
        }
    }
}

extension Array {
    subscript(maybe index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}

struct Item: Hashable {
    let url: URL
    var image: UIImage?
    
    init(url: URL) {
        self.url = url
        image = nil
    }
}
