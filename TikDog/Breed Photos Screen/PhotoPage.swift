//
//  Photos.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import UIKit

// This type can be further improved to achieve more type safety.
// We can encode number of items for each section.
struct PhotoPage: Equatable {
    var topItem: PhotoItem
    var middleSection: [PhotoItem]
    var bottomSection: [PhotoItem]
}

extension PhotoPage: Decodable {
    typealias Section = BreedPhotosViewController.Section
    
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urls = try container.decode([URL].self, forKey: .message)
        
        guard let firstURL = urls.first else {
            throw DecodingError.typeMismatch(
                PhotoPage.self,
                DecodingError.Context(codingPath: [], debugDescription: "Expected to get at least one URL")
            )
        }
        topItem = PhotoItem(url: firstURL)
        middleSection = []
        bottomSection = []
        
        let middleSectionLowerBound = Section.top.numberOfItems
        let middleSectionUpperBound = Section.middle.numberOfItems
        let bottomSectionLowerBound = Section.top.numberOfItems + Section.middle.numberOfItems
        let bottomSectionUpperBound = Section.middle.numberOfItems + Section.bottom.numberOfItems
        for (index, url) in urls.enumerated() {
            switch index {
            case (middleSectionLowerBound...middleSectionUpperBound):
                middleSection.append(PhotoItem(url: url))
                
            case (bottomSectionLowerBound...bottomSectionUpperBound):
                bottomSection.append(PhotoItem(url: url))
                
            default:
                break
            }
        }
    }
}

extension PhotoPage {
    subscript(indexPath: IndexPath) -> PhotoItem {
        get {
            switch (indexPath.section, indexPath.row) {
            case (Section.top.index, 0..<Section.top.numberOfItems):
                return topItem
                
            case (Section.middle.index, 0..<Section.middle.numberOfItems):
                return middleSection[indexPath.row]
                
            case (Section.bottom.index, 0..<Section.bottom.numberOfItems):
                return bottomSection[indexPath.row]
                
            default:
                fatalError("Index out of range")
            }
        }
        set {
            switch (indexPath.section, indexPath.row) {
            case (Section.top.index, 0..<Section.top.numberOfItems):
                topItem = newValue
                
            case (Section.middle.index, 0..<Section.middle.numberOfItems):
                middleSection[indexPath.row] = newValue
                
            case (Section.bottom.index, 0..<Section.bottom.numberOfItems):
                bottomSection[indexPath.row] = newValue
                
            default:
                fatalError("Index out of range")
            }
        }
    }
}

struct PhotoItem: Hashable {
    //TODO: it's a good idea to use UUID to prevent crash for items with same URLs
    let url: URL
    var image: UIImage?
}
