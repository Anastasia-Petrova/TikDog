//
//  BreedPhotosViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedPhotosViewController: UICollectionViewController {
    lazy var dataSource = BreedPhotosDataSource(
        initialState: .loading,
        collectionView: collectionView,
        retryAction: fetchBreedPhotos
    )
    let breed: Breed
    let getBreedPhotos: () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
    var subscription: AnyCancellable?
    
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
        fetchBreedPhotos()
    }
    
    func fetchBreedPhotos() {
        dataSource.state = .loading
        subscription = getBreedPhotos()
            .receive(on: DispatchQueue.main)
            .sink { [weak dataSource] result in
                switch result {
                case let .success(response):
                    dataSource?.state = .loaded(response.photoURLs)
                    
                case let .failure(error):
                    dataSource?.state = .failed(error)
                }
            }
    }
}

enum BreedPhotosCollectionLayout {
    static func make() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            Section(sectionIndex).layout
        }
    }
}

final class BreedPhotosDataSource: NSObject, UICollectionViewDataSource {
    var state: Loadable<[URL]> {
        didSet {
            collectionView.reloadData()
        }
    }
    let retryAction: () -> Void
    let collectionView: UICollectionView
    
    init(
        initialState: Loadable<[URL]>,
        collectionView: UICollectionView,
        retryAction: @escaping () -> Void
    ) {
        self.state = initialState
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

enum Section: Int, CaseIterable {
    case top = 1
    case middle
    case bottom
    
    init(_ index: Int) {
        // Cycling over indexes of all sections.
        // top, middle, bottom, top, middle, bottom etc.
        self.init(rawValue: (abs(index) % AllCases().count) + 1)! //safe to force unwrap, because we are cycling over case indexes. Crash means a programmer mistake.
    }
    
    var layout: NSCollectionLayoutSection {
        switch self {
        case .top:
            return makeTopSectionLayout()
            
        case .middle:
            return makeMiddleSectionLayout()
            
        case .bottom:
            return makeBottomSectionLayout()
        }
    }
    
    private func makeTopSectionLayout() -> NSCollectionLayoutSection {
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
    
    private func makeMiddleSectionLayout() -> NSCollectionLayoutSection {
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
    
    private func makeBottomSectionLayout() -> NSCollectionLayoutSection {
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
