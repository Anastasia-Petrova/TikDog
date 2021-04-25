//
//  BreedListDataSourceTests.swift
//  TikDogTests
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
@testable import TikDog
import XCTest

final class BreedListDataSourceTests: XCTestCase {
    func test_numberOfRowsInSection() {
        let dataSource = makeDataSource()
        dataSource.state = .failed(WebError(message: "", code: 0))
        XCTAssertEqual(dataSource.tableView(UITableView(), numberOfRowsInSection: 0), 1)
        
        dataSource.state = .loading
        XCTAssertEqual(dataSource.tableView(UITableView(), numberOfRowsInSection: 0), 10)
        
        dataSource.state = .loaded([Breed(identifier: "pug"), Breed(identifier: "shiba")])
        XCTAssertEqual(dataSource.tableView(UITableView(), numberOfRowsInSection: 0), 2)
    }
    
    func test_cellForRowAtIndexPath() {
        func getCell() -> UITableViewCell {
            return dataSource.tableView(dataSource.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        }
        let dataSource = makeDataSource()
        dataSource.state = .failed(WebError(message: "", code: 0))
        XCTAssertTrue(getCell() is ErrorMessageCell)
        
        dataSource.state = .loading
        XCTAssertTrue(getCell() is BreedCell.Placeholder)
        
        dataSource.state = .loaded([Breed(identifier: "pug"), Breed(identifier: "shiba")])
        XCTAssertTrue(getCell() is BreedCell)
    }
    
    func test_fetch_setsStateToLoading_andMakesRequest() {
        var counter = 0
        let dataSource = makeDataSource(
            initialState: .failed(WebError(message: "", code: 0)),
            breedsListPublisher: {
                counter += 1
                return WebService.mockSuccess.getBreedsList()
            }
        )
        XCTAssertNil(dataSource.breedsListRequestSubscription, "precondition")
        dataSource.fetch()
        
        XCTAssertEqual(dataSource.state, .loading)
        XCTAssertEqual(counter, 1)
        XCTAssertNotNil(dataSource.breedsListRequestSubscription)
    }
    
    func test_getBreed() {
        let dataSource = makeDataSource()
        dataSource.state = .failed(WebError(message: "", code: 0))
        XCTAssertNil(dataSource.getBreed(at: IndexPath(row: 0, section: 0)))
        
        dataSource.state = .loading
        XCTAssertNil(dataSource.getBreed(at: IndexPath(row: 0, section: 0)))
        
        dataSource.state = .loaded([Breed(identifier: "pug"), Breed(identifier: "shiba")])
        XCTAssertEqual(dataSource.getBreed(at: IndexPath(row: 0, section: 0)), Breed(identifier: "pug"))
    }
    
    func test_update() {
        let dataSource = makeDataSource()
        dataSource.state = .failed(WebError(message: "", code: 0))
        dataSource.update()
        XCTAssertFalse(dataSource.tableView.allowsSelection)
        XCTAssertFalse(dataSource.tableView.isScrollEnabled)
        
        
        dataSource.state = .loading
        dataSource.update()
        XCTAssertFalse(dataSource.tableView.allowsSelection)
        XCTAssertFalse(dataSource.tableView.isScrollEnabled)
        
        dataSource.state = .loaded([Breed(identifier: "pug"), Breed(identifier: "shiba")])
        dataSource.update()
        XCTAssertTrue(dataSource.tableView.allowsSelection)
        XCTAssertTrue(dataSource.tableView.isScrollEnabled)
    }
    
    private func makeDataSource(
        initialState: Loadable<[Breed]> = .loading,
        breedsListPublisher: @escaping () -> AnyPublisher<Result<BreedListResponse, WebError>, Never> = WebService.mockSuccess.getBreedsList
    ) -> BreedListDataSource {
        BreedListDataSource(
            initialState: .loading,
            tableView: UITableView(),
            breedsListPublisher: breedsListPublisher,
            retryAction: { }
        )
    }
}
