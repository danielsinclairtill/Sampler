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
    private let mockEnvironment: SamplerEnvironmentMock = SamplerEnvironmentMock()
    private let mockCoordinator = ItemsListCoordinator(parentCoordinator: nil,
                                                       navigationController: UINavigationController())
    private var cancelBag = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockEnvironment.reset()
        cancelBag = Set<AnyCancellable>()
    }
    
    func testItemDetailLoad() {
        let item = ModelMockData.makeItem(id: itemId)
        let user = ModelMockData.makeUser(id: itemId)
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(item),
            .success(user)
        ]
        let viewModel = ItemDetailViewModel(itemId: itemId,
                                            environment: mockEnvironment,
                                            coordinator: mockCoordinator)
        
        viewModel.input.viewDidLoad.send(())
        
        waitForValue(viewModel.output.$item, toBe: item)
        waitForValue(viewModel.output.$user, toBe: user)

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
                                            environment: mockEnvironment,
                                            coordinator: mockCoordinator)
        
        viewModel.input.viewDidLoad.send(())

        waitForValue(viewModel.output.$error, toBe: APIError.serverError.message)

        let expectedRequest = ItemAPIRequest.Detail(id: itemId)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
        XCTAssertEqual(viewModel.output.item, nil)
        XCTAssertEqual(viewModel.output.user, nil)
    }
}
