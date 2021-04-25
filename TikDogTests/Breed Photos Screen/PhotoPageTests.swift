//
//  PhotoPageTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class PhotoPageTests: XCTestCase {
    func test_decoding() throws {
        let expected = PhotoPage(
            topItem: PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_11614.jpg")!),
            middleSection: [
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_11853.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_11858.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_12997.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_13553.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_2383.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_3026.jpg")!),
            ],
            bottomSection: [
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_4086.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_6869.jpg")!),
                PhotoItem(url: URL(string: "https://images.dog.ceo/breeds/affenpinscher/n02110627_7680.jpg")!),

            ]
        )
        let jsonData = """
        {
            "message": [
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_11614.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_11853.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_11858.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_12997.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_13553.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_2383.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_3026.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_4086.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_6869.jpg",
                "https://images.dog.ceo/breeds/affenpinscher/n02110627_7680.jpg"
            ],
            "status": "success"
        }
        """.data(using: .utf8)!
        
        let actual = try JSONDecoder().decode(PhotoPage.self, from: jsonData)

        XCTAssertEqual(actual, expected)
    }
    
    func test_subscript_getter() throws {
        let mock = PhotoPage.mock()
        let item0 = mock[IndexPath(row: 0, section: 0)]
        let item1 = mock[IndexPath(row: 0, section: 1)]
        let item2 = mock[IndexPath(row: 1, section: 1)]
        let item3 = mock[IndexPath(row: 2, section: 1)]
        let item4 = mock[IndexPath(row: 3, section: 1)]
        let item5 = mock[IndexPath(row: 4, section: 1)]
        let item6 = mock[IndexPath(row: 5, section: 1)]
        let item7 = mock[IndexPath(row: 0, section: 2)]
        let item8 = mock[IndexPath(row: 1, section: 2)]
        let item9 = mock[IndexPath(row: 2, section: 2)]
        
        XCTAssertEqual(item0, mock.topItem)
        XCTAssertEqual(item1, mock.middleSection[0])
        XCTAssertEqual(item2, mock.middleSection[1])
        XCTAssertEqual(item3, mock.middleSection[2])
        XCTAssertEqual(item4, mock.middleSection[3])
        XCTAssertEqual(item5, mock.middleSection[4])
        XCTAssertEqual(item6, mock.middleSection[5])
        XCTAssertEqual(item7, mock.bottomSection[0])
        XCTAssertEqual(item8, mock.bottomSection[1])
        XCTAssertEqual(item9, mock.bottomSection[2])
    }
    
    func test_subscript_setter() throws {
        let mockImage = UIImage()
        var mock = PhotoPage.mock()
        mock[IndexPath(row: 0, section: 0)].image = mockImage
        mock[IndexPath(row: 0, section: 1)].image = mockImage
        mock[IndexPath(row: 1, section: 1)].image = mockImage
        mock[IndexPath(row: 2, section: 1)].image = mockImage
        mock[IndexPath(row: 3, section: 1)].image = mockImage
        mock[IndexPath(row: 4, section: 1)].image = mockImage
        mock[IndexPath(row: 5, section: 1)].image = mockImage
        mock[IndexPath(row: 0, section: 2)].image = mockImage
        mock[IndexPath(row: 1, section: 2)].image = mockImage
        mock[IndexPath(row: 2, section: 2)].image = mockImage
        
        XCTAssertEqual(mockImage, mock.topItem.image)
        XCTAssertEqual(mockImage, mock.middleSection[0].image)
        XCTAssertEqual(mockImage, mock.middleSection[1].image)
        XCTAssertEqual(mockImage, mock.middleSection[2].image)
        XCTAssertEqual(mockImage, mock.middleSection[3].image)
        XCTAssertEqual(mockImage, mock.middleSection[4].image)
        XCTAssertEqual(mockImage, mock.middleSection[5].image)
        XCTAssertEqual(mockImage, mock.bottomSection[0].image)
        XCTAssertEqual(mockImage, mock.bottomSection[1].image)
        XCTAssertEqual(mockImage, mock.bottomSection[2].image)
    }
}
