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

@MainActor
class ItemDetailViewModelTests: XCTestCase {
    private let itemId = "123"
    private var mockEnvironment: SamplerEnvironmentMock!
    
    override func setUp() {
        super.setUp()
        mockEnvironment = SamplerEnvironmentMock()
        mockEnvironment.reset()
    }
    
    override func tearDown() async throws {
        mockEnvironment = nil
        try await super.tearDown()
    }
    
    func testItemDetailLoad() async {
        let item = ModelMockData.makeItem(id: itemId)
        let user = ModelMockData.makeUser(id: itemId)
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(item),
            .success(user)
        ]
        let viewModel = ItemDetailViewModel(itemId: itemId,
                                            environment: mockEnvironment)
        
        viewModel.viewDidLoad()
        
        await Task.yield()
        
        XCTAssertEqual(viewModel.output.item, item)
        XCTAssertEqual(viewModel.output.user, user)

        let expectedRequest = ItemAPIRequest.Detail(id: itemId)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 2)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
    }
    
    func testItemDetailPresentsError() {
        let itemId = "123"
        mockEnvironment.mockApi.mockAPIResponses = [
            .failure(APIError.serverError)
        ]
        let viewModel = ItemDetailViewModel(itemId: itemId,
                                            environment: mockEnvironment)
        
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.output.error, APIError.serverError.message)

        let expectedRequest = ItemAPIRequest.Detail(id: itemId)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
        XCTAssertEqual(viewModel.output.item, nil)
        XCTAssertEqual(viewModel.output.user, nil)
    }
}
