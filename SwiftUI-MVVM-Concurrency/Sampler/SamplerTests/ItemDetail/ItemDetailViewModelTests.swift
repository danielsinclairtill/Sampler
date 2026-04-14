//
//  ItemDetailViewModelTests.swift
//  SamplerTests
//
//  Created by Daniel Till on 2023-08-22.
//

import Foundation
import XCTest
import Combine
@testable import Sampler

class ItemDetailViewModelTests: XCTestCase {
    private let itemId = "123"
    private var mockEnvironment = SamplerEnvironmentMock()
    
    override func setUp() {
        super.setUp()
        mockEnvironment.reset()
    }
    
    func testItemDetailLoadAPI() async {
        let user = ModelMockData.makeUser(id: itemId)
        let item = ModelMockData.makeItem(id: itemId, userId: user.id, user: nil)
        var expected = item
        expected.user = user
        
        mockEnvironment.mockStore.mockGetResponses = [
            .success(nil),
        ]
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(item),
            .success(user)
        ]
        let viewModel = ItemDetailViewModel(itemId: itemId,
                                            environment: mockEnvironment)
        
        await viewModel.viewDidLoad()
                
        XCTAssertEqual(viewModel.output.item, expected)

        let expectedRequest = ItemAPIRequest.Detail(id: itemId)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 2)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
    }
    
    func testItemDetailLoadStore() async {
        let item = ModelMockData.makeItem(id: itemId,
                                          user: ModelMockData.makeUser(id: itemId))
        
        mockEnvironment.mockStore.mockGetResponses = [
            .success(item)
        ]
        let viewModel = ItemDetailViewModel(itemId: itemId,
                                            environment: mockEnvironment)
        
        await viewModel.viewDidLoad()
                
        XCTAssertEqual(viewModel.output.item, item)
        XCTAssertEqual(viewModel.output.isSaved, true)

        let expectedRequest = ItemStoreRequest.GetDetail(id: itemId)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 0)
        XCTAssertTrue(mockEnvironment.mockStore.mockGetRequestsCalled.contains { $0.id == expectedRequest.id })
    }
    
    func testItemDetailPresentsError() async {
        let itemId = "123"
        
        mockEnvironment.mockStore.mockGetResponses = [
            .success(nil),
        ]
        mockEnvironment.mockApi.mockAPIResponses = [
            .failure(APIError.serverError)
        ]
        let viewModel = ItemDetailViewModel(itemId: itemId,
                                            environment: mockEnvironment)
        
        await viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.output.error, APIError.serverError.message)

        let expectedRequest = ItemAPIRequest.Detail(id: itemId)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
        XCTAssertEqual(viewModel.output.item, nil)
    }
}
