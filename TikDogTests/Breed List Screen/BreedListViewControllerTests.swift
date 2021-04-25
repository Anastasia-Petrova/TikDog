//
//  BreedListViewControllerTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

@testable import TikDog
import XCTest

final class BreedListViewControllerTests: XCTestCase {
    func test_didSelectRow_performsCallback() {
        var capturedBreeds: [Breed] = []
        
        let vc = BreedListViewController(
            breedListPublisher: WebService.mockSuccess.getBreedsList,
            didSelectBreed: { breed in
                capturedBreeds.append(breed)
            }
        )
        vc.dataSource.state = .loaded([Breed(name: "pug")])
        
        vc.tableView(UITableView(), didSelectRowAt: IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(capturedBreeds, [Breed(name: "pug")])
    }
    
    func test_viewDidLoad_setsDataSource() throws {
        let vc = BreedListViewController(
            breedListPublisher: WebService.mockSuccess.getBreedsList,
            didSelectBreed: { _ in }
        )
        vc.loadViewIfNeeded()
        let tableDataSource = try XCTUnwrap(vc.tableView.dataSource as? BreedListDataSource)
        let dataSource = try XCTUnwrap(vc.dataSource as? BreedListDataSource)
        
        XCTAssertEqual(tableDataSource, dataSource)
    }
    
    func test_viewDidLoad_callsFetch() throws {
        let vc = BreedListViewController(
            breedListPublisher: WebService.mockSuccess.getBreedsList,
            didSelectBreed: { _ in }
        )
        let spy = SpyTableDataSource()
        vc.dataSource = spy
        vc.loadViewIfNeeded()
        
        XCTAssertEqual(spy.fetchCallCount, 1)
    }
}

private final class SpyTableDataSource: NSObject, TableDataSource {
    var fetchCallCount: Int = 0
    
    var state: Loadable<[Breed]> = .loading
    func fetch() {
        fetchCallCount += 1
    }
    func getBreed(at indexPath: IndexPath) -> Breed? { nil }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
