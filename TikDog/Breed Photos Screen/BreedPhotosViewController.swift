//
//  BreedPhotosViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedPhotosViewController: UICollectionViewController {
    let dataSource = BreedPhotosDataSource()
    let breed: Breed
    let getBreedPhotos: () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
    
    init(
        breed: Breed,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
    ) {
        self.breed = breed
        self.getBreedPhotos = getBreedPhotos
        super.init(collectionViewLayout: BreedPhotosCollectionLayout.make())
        view.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(BreedPhotoCell.self, forCellWithReuseIdentifier: BreedPhotoCell.identifier)
        collectionView.dataSource = dataSource
    }
}

enum BreedPhotosCollectionLayout {
    static func make() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let oneBasedIndex = sectionIndex + 1
            if oneBasedIndex % 3 == 0 {
                return makeBottomSectionLayout()
            } else if oneBasedIndex % 2 == 0 {
                return makeMiddleSectionLayout()
            } else {
                return makeTopSectionLayout()
            }
        }
    }
    
    private static func makeTopSectionLayout() -> NSCollectionLayoutSection {
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
    
    private static func makeMiddleSectionLayout() -> NSCollectionLayoutSection {
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
    
    private static func makeBottomSectionLayout() -> NSCollectionLayoutSection {
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

final class BreedPhotosDataSource: NSObject, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let oneBasedIndex = section +  1
        if oneBasedIndex % 3 == 0 {
            return 3
        } else if oneBasedIndex % 2 == 0 {
            return 6
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPhotoCell.identifier, for: indexPath) as! BreedPhotoCell
        
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
    }
}

final class BreedPhotoCell: UICollectionViewCell {
    static let identifier = String(describing: BreedPhotoCell.self)
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Loadable<Content> {
    case failed(WebError)
    case loaded(Content)
    case loading
}
