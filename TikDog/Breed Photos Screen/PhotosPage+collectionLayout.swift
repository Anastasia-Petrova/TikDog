//
//  Page+collectionLayout.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation
import UIKit

protocol SectionLayout {
    static var layout: NSCollectionLayoutSection { get }
}

extension PhotosPage {
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
}

extension PhotosPage.Section.Top: SectionLayout {
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

extension PhotosPage.Section.Middle: SectionLayout {
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

extension PhotosPage.Section.Bottom: SectionLayout {
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
