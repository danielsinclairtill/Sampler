//
//  ItemsListViewModelTests.swift
//  Sampler
//
//
//
//

import XCTest
import Combine
@testable import Sampler

class ItemsListViewModelTests: XCTestCase {
    private let mockEnvironment: SamplerEnvironmentMock = SamplerEnvironmentMock()
    private var mockRouter = ItemsListRouter()
    private var cancelBag = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockEnvironment.reset()
        cancelBag = Set<AnyCancellable>()
    }
    
    // MARK: Online
    func testRefreshSampler() {
        let mockItems: [Item] = ModelMockData.makeMockItems(count: 10)
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(ItemAPIRequest.List.Response(items: mockItems, total: 10, offset: 0))
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           router: mockRouter)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refreshBegin.send(())
        
        XCTAssertTrue(viewModel.output.isRefreshing)
        
        viewModel.input.refresh.send(())
        
        waitForValue(viewModel.output.$items, toBe: mockItems)
        
        let expectedRequest = ItemAPIRequest.List()
        XCTAssertFalse(viewModel.output.isRefreshing)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
    }
    
    func testRefreshSamplerServerError() {
        mockEnvironment.mockApi.mockAPIResponses = [
            .failure(.serverError)
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           router: mockRouter)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refresh.send(())
        
        waitForValue(viewModel.output.$error, toBe: APIError.serverError.message)
        
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
    }
    
    func testRefreshSamplerEmptyError() {
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(ItemAPIRequest.List.Response(items: [], total: 0, offset: 0))
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           router: mockRouter)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refresh.send(())
        
        waitForValue(viewModel.output.$error, toBe: APIError.serverError.message)
        
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
    }
    
    func testRefreshSamplerLostConnectionError() {
        mockEnvironment.mockApi.mockAPIResponses = [
            .failure(.lostConnection)
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           router: mockRouter)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refresh.send(())
        
        waitForValue(viewModel.output.$error, toBe: APIError.lostConnection.message)
        
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
    }
    
    func testRefreshSamplerImagesArePrefetched() {
        let mockItems: [Item] = ModelMockData.makeMockItems(count: 10)
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(ItemAPIRequest.List.Response(items: mockItems, total: 10, offset: 0))
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           router: mockRouter)
        
        XCTAssertTrue(mockEnvironment.mockApi.mockImageManager.mockPrefetchTaskURLs.isEmpty)
        
        viewModel.input.refresh.send(())
        
        waitForValue(viewModel.output.$items, toBe: mockItems)
        
        // prefetches only the first 10 images
        let prefetchImageURLs: [URL] = Array(mockItems.prefix(upTo: 10)).compactMap { $0.image }
        XCTAssertEqual(mockEnvironment.mockApi.mockImageManager.mockPrefetchTaskURLs, prefetchImageURLs)
    }
}
