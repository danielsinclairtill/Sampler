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
    private let mockCoordinator = ItemsListCoordinator(parentCoordinator: nil,
                                                       navigationController: UINavigationController())
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
                                           coordinator: mockCoordinator)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refreshBegin.send(())
        
        XCTAssertTrue(viewModel.output.isRefreshing)
        
        viewModel.input.refresh.send(())
        
        let expectedRequest = ItemAPIRequest.List()
        XCTAssertFalse(viewModel.output.isRefreshing)
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertTrue(mockEnvironment.mockApi.mockAPIRequestsCalled.contains { $0.path == expectedRequest.path })
        XCTAssertEqual(viewModel.output.items, mockItems)
    }
    
    func testRefreshSamplerServerError() {
        mockEnvironment.mockApi.mockAPIResponses = [
            .failure(.serverError)
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           coordinator: mockCoordinator)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refresh.send(())
        
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertEqual(viewModel.output.error, APIError.serverError.message)
    }
    
    func testRefreshSamplerEmptyError() {
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(ItemAPIRequest.List.Response(items: [], total: 0, offset: 0))
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           coordinator: mockCoordinator)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refresh.send(())
        
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertEqual(viewModel.output.error, APIError.serverError.message)
    }
    
    func testRefreshSamplerLostConnectionError() {
        mockEnvironment.mockApi.mockAPIResponses = [
            .failure(.lostConnection)
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           coordinator: mockCoordinator)
        
        XCTAssertTrue(viewModel.output.items.isEmpty)
        
        viewModel.input.refresh.send(())
        
        XCTAssertEqual(mockEnvironment.mockApi.mockAPIRequestsCalled.count, 1)
        XCTAssertEqual(viewModel.output.error, APIError.lostConnection.message)
    }
    
    func testRefreshSamplerImagesArePrefetched() {
        let mockItems: [Item] = ModelMockData.makeMockItems(count: 10)
        mockEnvironment.mockApi.mockAPIResponses = [
            .success(ItemAPIRequest.List.Response(items: mockItems, total: 10, offset: 0))
        ]
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           coordinator: mockCoordinator)
        
        XCTAssertTrue(mockEnvironment.mockApi.mockImageManager.mockPrefetchTaskURLs.isEmpty)
        
        viewModel.input.refresh.send(())
        
        // prefetches only the first 10 images
        let prefetchImageURLs: [URL] = Array(mockItems.prefix(upTo: 10)).compactMap { $0.image }
        XCTAssertEqual(mockEnvironment.mockApi.mockImageManager.mockPrefetchTaskURLs, prefetchImageURLs)
    }
    
    // MARK: TabBarItem
    func testTapTabBarItemDoesScrollToTop() {
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           coordinator: mockCoordinator)
        var scrollToTopCount = 0
        viewModel.input.isTopOfPage = false
        viewModel.input.isScrolling = false
        
        viewModel.output.scrollToTop
            .sink { _ in
                scrollToTopCount += 1
            }
            .store(in: &cancelBag)
        
        mockCoordinator.tabBarItemTappedWhileDisplayed.send(())
        
        XCTAssertEqual(scrollToTopCount, 1)
    }
    
    func testTapTabBarItemDoesNotScrollsToTopWhileScrolling() {
        let viewModel = ItemsListViewModel(environment: mockEnvironment,
                                           coordinator: mockCoordinator)
        viewModel.input.isTopOfPage = false
        viewModel.input.isScrolling = true
        
        viewModel.output.scrollToTop
            .sink { _ in
                XCTFail("scrollToTop called while scrolling")
            }
            .store(in: &cancelBag)
        
        mockCoordinator.tabBarItemTappedWhileDisplayed.send(())
    }
}
