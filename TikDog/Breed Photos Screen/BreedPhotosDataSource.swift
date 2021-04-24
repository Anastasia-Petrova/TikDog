//
//  BreedPhotosDataSource.swift
//  TikDog
//
//  Created by Anastasia Petrova on 24/04/2021.
//

import Combine
import Foundation
import UIKit

struct Page {
    var topSection: Section.Top
    var middleSection: Section.Middle?
    var bottomSection: Section.Bottom?
    
    static let numberOfSections = 3
    
    static var layout: UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                return Section.Top.layout
            case 1:
                return Section.Middle.layout
            case 2:
                return Section.Bottom.layout
            default:
                return nil
            }
        }
    }
    
    static var numberOfItems: Int {
        Section.Top.numberOfItems + Section.Middle.numberOfItems + Section.Bottom.numberOfItems
    }
    
    static func numberOfItems(in sectionIndex: Int) -> Int {
        switch sectionIndex {
        case 0:
            return Section.Top.numberOfItems
        case 1:
            return Section.Middle.numberOfItems
        case 2:
            return Section.Bottom.numberOfItems
        default:
            fatalError("Index out of range")
        }
    }
    
    subscript(indexPath: IndexPath) -> Item? {
        get {
            let rowIndex = indexPath.row
            
            switch indexPath.section {
            case 0:
                guard rowIndex == 0 else { fatalError("Index out of range") }
                return topSection.item
                
            case 1:
                switch rowIndex {
                case 0:
                    return middleSection?.leadingColumn.top
                case 1:
                    return middleSection?.leadingColumn.bottom
                case 2:
                    return middleSection?.centralColumn?.top
                case 3:
                    return middleSection?.centralColumn?.bottom
                case 4:
                    return middleSection?.trailingColumn?.top
                case 5:
                    return middleSection?.trailingColumn?.bottom
                default:
                    fatalError("Index out of range")
                }
                
            case 2:
                switch rowIndex {
                case 0:
                    return bottomSection?.leadingItem
                case 1:
                    return bottomSection?.trailingColumn?.top
                case 2:
                    return bottomSection?.trailingColumn?.bottom
                default:
                    fatalError("Index out of range")
                }
            default:
                fatalError("Index out of range")
            }
        }
        set {
            guard let newValue = newValue else { return }
            let rowIndex = indexPath.row
            
            switch indexPath.section {
            case 0:
                guard rowIndex == 0 else { fatalError("Index out of range") }
                topSection.item = newValue
                
            case 1:
                switch rowIndex {
                case 0:
                    middleSection?.leadingColumn.top = newValue
                case 1:
                    middleSection?.leadingColumn.bottom = newValue
                case 2:
                    middleSection?.centralColumn?.top = newValue
                case 3:
                    middleSection?.centralColumn?.bottom = newValue
                case 4:
                    middleSection?.trailingColumn?.top = newValue
                case 5:
                    middleSection?.trailingColumn?.bottom = newValue
                default:
                    fatalError("Index out of range")
                }
                
            case 2:
                switch rowIndex {
                case 0:
                    bottomSection?.leadingItem = newValue
                case 1:
                    bottomSection?.trailingColumn?.top = newValue
                case 2:
                    bottomSection?.trailingColumn?.bottom = newValue
                default:
                    fatalError("Index out of range")
                }
            default:
                fatalError("Index out of range")
            }
        }
    }
    
    var items: [Item] {
        [topSection.item] + (middleSection?.items ?? []) + (bottomSection?.items ?? [])
    }
    
    enum Section: Hashable {
        case top(Top)
        case middle(Middle)
        case bottom(Bottom)
        
        func numberOfItems(availableItems: Int = 10) -> Int {
            switch self {
            case .top:
                return min(Top.numberOfItems, availableItems)
                
            case .middle:
                return min(Middle.numberOfItems, availableItems - Top.numberOfItems)
                
            case .bottom:
                return min(Bottom.numberOfItems, availableItems - Middle.numberOfItems - Top.numberOfItems)
            }
        }
        
        struct Column: Hashable {
            var top: Item
            var bottom: Item?
            
            var items: [Item] {
                [top, bottom].compactMap { $0 }
            }

            subscript(index: Int) -> Item? {
                switch index {
                case 0:
                    return top
                case 1:
                    return bottom
                default:
                    return nil
                }
            }
        }
        
        struct Top: Hashable {
            var item: Item
            var numberOfItems: Int { 1 }
            
            static let numberOfItems = 1
        }
        
        struct Middle: Hashable {
            var leadingColumn: Column
            var centralColumn: Column?
            var trailingColumn: Column?
            
            var items: [Item] {
                leadingColumn.items + (centralColumn?.items ?? []) + (trailingColumn?.items ?? [])
            }
            var numberOfItems: Int { items.count }
            
            static let numberOfItems: Int = 6
        }
        
        struct Bottom: Hashable {
            var leadingItem: Item
            var trailingColumn: Column?
            
            var items: [Item] {
                [leadingItem] + (trailingColumn?.items ?? [])
            }
            
            var numberOfItems: Int { items.count }
            
            static let numberOfItems: Int = 3
        }
    }
}

protocol SectionLayout {
    static var layout: NSCollectionLayoutSection { get }
}

extension Page.Section.Top: SectionLayout {
    static var layout: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0/3.0)
            ),
            subitems: [item]
        )
        return NSCollectionLayoutSection(group: group)
    }
}

extension Page.Section.Middle: SectionLayout {
    static var layout: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0/3.0)
            )
        )
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0/3.0),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitem: item,
            count: 2
        )
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0/3.0)
            ),
            subitem: verticalGroup,
            count: 3
        )
        return NSCollectionLayoutSection(group: horizontalGroup)
    }
}

extension Page.Section.Bottom: SectionLayout {
    static var layout: NSCollectionLayoutSection {
        let leadingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2.0/3.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let trailingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0/3.0)
            )
        )
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0/3.0),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitem: trailingItem,
            count: 2
        )

        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0/3.0)
            ),
            subitems: [leadingItem, trailingGroup]
        )
        return NSCollectionLayoutSection(group: nestedGroup)
    }
}

extension Array {
    subscript(maybe index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}

extension Page: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urls = try container.decode([URL].self, forKey: .message)
        
        guard urls.count > 0 else {
            throw DecodingError.typeMismatch(
                Page.self,
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

struct Item: Hashable {
    let url: URL
    var image: UIImage?
    
    init(url: URL) {
        self.url = url
        image = nil
    }
}
