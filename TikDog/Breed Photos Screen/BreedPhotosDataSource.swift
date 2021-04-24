//
//  BreedPhotosDataSource.swift
//  TikDog
//
//  Created by Anastasia Petrova on 24/04/2021.
//

import Combine
import Foundation
import UIKit

final class BreedPhotosDataSource: NSObject, UICollectionViewDataSource {
    var state: Loadable<Page> {
        didSet {
            collectionView.reloadData()
        }
    }
    let loadImage: (URL) -> AnyPublisher<UIImage?, Never>
    let retryAction: () -> Void
    let collectionView: UICollectionView
    var subscriptions = Set<AnyCancellable>()
    
    init(
        initialState: Loadable<Page>,
        collectionView: UICollectionView,
        loadImage: @escaping (URL) -> AnyPublisher<UIImage?, Never>,
        retryAction: @escaping () -> Void
    ) {
        self.state = initialState
        self.loadImage = loadImage
        self.retryAction = retryAction
        self.collectionView = collectionView
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch state {
        case .loading,
             .loaded:
            return Page.numberOfSections
            
        case .failed:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch state {
        case .loading,
             .loaded:
            return Page.numberOfItems(in: section)
            
        case .failed:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
        
        switch state {
        case .loading:
            cell.contentView.backgroundColor = .gray
            return cell
            
        case let .loaded(page):
            let item = page[indexPath]
            cell.title.text = String(indexPath.row)
            if let image = item.image {
                cell.imageView.image = image
            } else {
                let url = item.url
                loadImage(url)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        if let image = image {
                            self?.setImage(image, indexPath: indexPath)
                        }
                    }
                    .store(in: &subscriptions)
            }
            return cell
            
        case .failed:
            return cell
        }
    }
    
    func setImage(_ image: UIImage, indexPath: IndexPath) {
        switch state {
        case var .loaded(page):
            page[indexPath].image = image
            state = .loaded(page)
        default:
            break
        }
    }
}

struct Page {
    var topSection: Section.Top
    var middleSection: Section.Middle
    var bottomSection: Section.Bottom
    
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
    
    subscript(sectionIndex: Int) -> Section {
        switch sectionIndex {
        case 0:
            return .top(topSection)
        case 1:
            return .middle(middleSection)
        case 2:
            return .bottom(bottomSection)
        default:
            fatalError("Index out of range")
        }
    }
    
    subscript(url: URL) -> IndexPath? {
        if topSection.item.url == url {
            return IndexPath(item: 0, section: 0)
            
        } else if let index = middleSection.items.firstIndex(where: { $0.url == url }) {
            return IndexPath(item: index, section: 1)
            
        } else if let index = bottomSection.items.firstIndex(where: { $0.url == url }) {
            return IndexPath(item: index, section: 2)
            
        } else {
            return nil
        }
    }
    
    subscript(indexPath: IndexPath) -> Item {
        get {
            let rowIndex = indexPath.row
            
            switch indexPath.section {
            case 0:
                guard rowIndex == 0 else { fatalError("Index out of range") }
                return topSection.item
                
            case 1:
                switch rowIndex {
                case 0:
                    return middleSection.leadingColumn.top
                case 1:
                    return middleSection.leadingColumn.bottom
                case 2:
                    return middleSection.centralColumn.top
                case 3:
                    return middleSection.centralColumn.bottom
                case 4:
                    return middleSection.trailingColumn.top
                case 5:
                    return middleSection.trailingColumn.bottom
                default:
                    fatalError("Index out of range")
                }
                
            case 2:
                switch rowIndex {
                case 0:
                    return bottomSection.leadingItem
                case 1:
                    return bottomSection.trailingColumn.top
                case 2:
                    return bottomSection.trailingColumn.bottom
                default:
                    fatalError("Index out of range")
                }
            default:
                fatalError("Index out of range")
            }
        }
        set {
            let rowIndex = indexPath.row
            
            switch indexPath.section {
            case 0:
                guard rowIndex == 0 else { fatalError("Index out of range") }
                topSection.item = newValue
                
            case 1:
                switch rowIndex {
                case 0:
                    middleSection.leadingColumn.top = newValue
                case 1:
                    middleSection.leadingColumn.bottom = newValue
                case 2:
                    middleSection.centralColumn.top = newValue
                case 3:
                    middleSection.centralColumn.bottom = newValue
                case 4:
                    middleSection.trailingColumn.top = newValue
                case 5:
                    middleSection.trailingColumn.bottom = newValue
                default:
                    fatalError("Index out of range")
                }
                
            case 2:
                switch rowIndex {
                case 0:
                    bottomSection.leadingItem = newValue
                case 1:
                    bottomSection.trailingColumn.top = newValue
                case 2:
                    bottomSection.trailingColumn.bottom = newValue
                default:
                    fatalError("Index out of range")
                }
            default:
                fatalError("Index out of range")
            }
        }
    }
    
    var items: [Item] {
        [topSection.item] + middleSection.items + bottomSection.items
    }
    
    enum Section {
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
        
        struct Column {
            var top: Item
            var bottom: Item
            
            var items: [Item] {
                [top, bottom]
            }
            
            subscript(url: URL) -> Item? {
                get {
                    switch url {
                    case top.url:
                        return top
                    case bottom.url:
                        return bottom
                    default:
                        return nil
                    }
                }
                set {
                    guard let newItem = newValue else { return }
                    
                    switch url {
                    case top.url:
                        top = newItem
                    case bottom.url:
                        bottom = newItem
                    default:
                        break
                    }
                }
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
        
        struct Top {
            var item: Item
            var numberOfItems: Int { 1 }
            
            static let numberOfItems = 1
        }
        
        struct Middle {
            var leadingColumn: Column
            var centralColumn: Column
            var trailingColumn: Column
            
            var items: [Item] {
                leadingColumn.items + centralColumn.items + trailingColumn.items
            }
            var numberOfItems: Int { items.count }
            
            static let numberOfItems: Int = 6
            
            subscript(url: URL) -> Item? {
                get {
                    leadingColumn[url] ?? centralColumn[url] ?? trailingColumn[url]
                }
                set {
                    guard let newItem = newValue else { return }
                    
                }
            }
        }
        
        struct Bottom {
            var leadingItem: Item
            var trailingColumn: Column
            
            var items: [Item] {
                [leadingItem] + trailingColumn.items
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


extension Page: Decodable {
    private enum CodingKeys: String, CodingKey {
        case photoURLs = "message"
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let urls = try container.decode([URL].self)
        guard urls.count == 10 else {
            throw DecodingError.typeMismatch(
                Page.self,
                DecodingError.Context(codingPath: [], debugDescription: "Expected to get exactly ten URLs")
            )
        }
        topSection = Section.Top(item: Item(url: urls[0]))
        middleSection = Section.Middle(
            leadingColumn: Section.Column(top: Item(url: urls[1]), bottom: Item(url: urls[2])),
            centralColumn: Section.Column(top: Item(url: urls[3]), bottom: Item(url: urls[4])),
            trailingColumn: Section.Column(top: Item(url: urls[5]), bottom: Item(url: urls[6]))
        )
        bottomSection = Section.Bottom(
            leadingItem: Item(url: urls[7]),
            trailingColumn: Section.Column(top: Item(url: urls[8]), bottom: Item(url: urls[9]))
        )
    }
}
