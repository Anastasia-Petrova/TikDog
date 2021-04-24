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
    var state: Loadable<[Item]> {
        didSet {
            collectionView.reloadData()
        }
    }
    let loadImage: (URL) -> AnyPublisher<UIImage?, Never>
    let retryAction: () -> Void
    let collectionView: UICollectionView
    var subscriptions = Set<AnyCancellable>()
    let photoLoadingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    init(
        initialState: Loadable<[Item]>,
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
        let numberOfElementsInFullPattern = 10
        let numberOfSectionsInFullPattern = 3
        switch state {
        case .loading:
            return numberOfSectionsInFullPattern
            
        case let .loaded(photoURLs):
            let numberOfFullPatterns = photoURLs.count / numberOfElementsInFullPattern
            let numberOfSectionsInPartialPattern: Int
            switch photoURLs.count % numberOfElementsInFullPattern {
            case 1:
                numberOfSectionsInPartialPattern = 1
            case 2...7:
                numberOfSectionsInPartialPattern = 2
            case 8...9:
                numberOfSectionsInPartialPattern = numberOfSectionsInFullPattern
            default:
                numberOfSectionsInPartialPattern = 0
            }
            return (numberOfFullPatterns * numberOfSectionsInFullPattern) + numberOfSectionsInPartialPattern
            
        case .failed:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionIndex: Int) -> Int {
        let section = Section(sectionIndex)
        
        switch state {
        case .loading:
            return numberOfItemsIn(section: section)
            
        case let .loaded(photoURLs):
            let numberOfSections = self.numberOfSections(in: collectionView)
            if sectionIndex == numberOfSections - 1 {
                let remainderInLastSection = photoURLs.count % 10
                return numberOfItemsIn(section: section, totalNumberOfItems: remainderInLastSection)
            } else {
                return numberOfItemsIn(section: section)
            }
            
        case .failed:
            return 1
        }
    }
    
    func numberOfItemsIn(section: Section, totalNumberOfItems: Int = 10) -> Int {
        switch section {
        case .top:
            return min(1, totalNumberOfItems)
        case .middle:
            return min(6, totalNumberOfItems - 1)
        case .bottom:
            return min(3, totalNumberOfItems - 7)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
        
        switch state {
        case .loading:
                if indexPath.section == 0 {
                    cell.contentView.backgroundColor = .yellow
                } else {
                    let oneBasedIndex = Int.random(in: (1...3))
                    if oneBasedIndex % 3 == 0 {
                        cell.contentView.backgroundColor = .green
                    } else if oneBasedIndex % 2 == 0 {
                        cell.contentView.backgroundColor = .blue
                    } else {
                        cell.contentView.backgroundColor = .red
                    }
                }
            return cell
            
        case let .loaded(items):
            let previousSection = indexPath.section > 0 ? Section(indexPath.section - 1) : nil
            let previousItemIndex = previousSection.map { numberOfItemsIn(section: $0) } ?? 0
            
            let totalIndex = previousItemIndex + indexPath.row
            let item = items[totalIndex]
            cell.title.text = String(totalIndex)
            if let image = item.image {
                cell.imageView.image = image
            } else {
                let url = item.url
                loadImage(url)
                    .subscribe(on: photoLoadingQueue)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        if let image = image {
                            self?.setImage(image, forURL: url)
                        }
                    }
                    .store(in: &subscriptions)
            }
            return cell
            
        case .failed:
            return cell
        }
    }
    
    func setImage(_ image: UIImage, forURL url: URL) {
        switch state {
        case var .loaded(items):
            guard let index = items.firstIndex (where: { $0.url == url }) else { return }
            items[index].image = image
            state = .loaded(items)
        default:
            break
        }
    }
}

struct Page {
    let topSection: Se.Top
    let middleSection: Se.Middle?
    let bottomSection: Se.Bottom?
    
    var numberOfItems: Int {
        topSection.numberOfItems + (middleSection?.numberOfItems ?? 0) + (bottomSection?.numberOfItems ?? 0)
    }
    
    subscript(indexPath: IndexPath) -> Item? {
        let sectionIndex = indexPath.section % 3
        let rowIndex = indexPath.row
        switch sectionIndex {
        case 0:
            guard rowIndex == 0 else { return nil }
            return topSection.item
            
        case 1:
            switch rowIndex {
            case 0:
                return middleSection?.leadingRow.top
            case 1:
                return middleSection?.leadingRow.bottom
            case 2:
                return middleSection?.centralRow?.top
            case 3:
                return middleSection?.centralRow?.bottom
            case 4:
                return middleSection?.trailingRow?.top
            case 5:
                return middleSection?.trailingRow?.bottom
            default:
                return nil
            }
            
        case 3:
            switch rowIndex {
            case 0:
                return bottomSection?.leadingItem
            case 1:
                return bottomSection?.trailingRow?.top
            case 2:
                return bottomSection?.trailingRow?.bottom
            default:
                return nil
            }
            
        default:
            return nil
        }
    }
    
    var items: [Item] {
        [topSection.item] + (middleSection?.items ?? []) + (bottomSection?.items ?? [])
    }
    
    enum Se {
        case top(Top)
        case middle(Middle)
        case bottom(Bottom)
        
        func numberOfItems(availableItems: Int = 10) -> Int {
            switch self {
            case .top:
                return min(Top.maxNumberOfItems, availableItems)
                
            case .middle:
                return min(Middle.maxNumberOfItems, availableItems - Top.maxNumberOfItems)
                
            case .bottom:
                return min(Bottom.maxNumberOfItems, availableItems - Middle.maxNumberOfItems - Top.maxNumberOfItems)
            }
        }
        
        struct VerticalRow {
            let top: Item
            let bottom: Item?
            
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
        
        struct Top {
            let item: Item
            var numberOfItems: Int { 1 }
            
            static let maxNumberOfItems = 1
        }
        
        struct Middle {
            let leadingRow: VerticalRow
            let centralRow: VerticalRow?
            let trailingRow: VerticalRow?
            
            var items: [Item] {
                leadingRow.items + (centralRow?.items ?? []) + (trailingRow?.items ?? [])
            }
            var numberOfItems: Int { items.count }
            
            static let maxNumberOfItems: Int = 6
        }
        
        struct Bottom {
            let leadingItem: Item
            let trailingRow: VerticalRow?
            
            var items: [Item] {
                [leadingItem] + (trailingRow?.items ?? [])
            }
            
            var numberOfItems: Int { items.count }
            
            static let maxNumberOfItems: Int = 3
        }
    }
}
