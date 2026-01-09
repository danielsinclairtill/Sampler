//
//  ItemsListViewTests.swift
//  Sampler
//
//  Created by Daniel on 2026-01-09.
//

import XCTest
@testable import Sampler
import SnapshotTesting

class ItemsListViewTests: XCTestCase {
    func testItemsList() {
        let items = ModelMockData.makeMockItems(count: 10)
        let viewModel = MockItemsListViewModel(items: items)
        let view = ItemsListViewController(viewModel: viewModel)
        viewModel.output.isRefreshing = false

        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }
    
    func testItemsListSmallDevice() {
        let items = ModelMockData.makeMockItems(count: 10)
        let viewModel = MockItemsListViewModel(items: items)
        let view = ItemsListViewController(viewModel: viewModel)
        
        assertSnapshot(of: view,
                       as: .image(on: .iPhoneSe,
                                  traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(on: .iPhoneSe,
                                  traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }
    
    func testItemsListLargeDevice() {
        let items = ModelMockData.makeMockItems(count: 10)
        let viewModel = MockItemsListViewModel(items: items)
        let view = ItemsListViewController(viewModel: viewModel)
        viewModel.output.isRefreshing = false
        
        assertSnapshot(of: view,
                       as: .image(on: .iPadPro11,
                                  traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(on: .iPadPro11,
                                  traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }
}

private class MockItemsListViewModel: ItemsListViewModelBinding.Contract {
    var input = ItemsListViewModelBinding.Input()
    var output: ItemsListViewModelBinding.Output
    var imageManager: any Sampler.ImageManagerContract = SamplerImageManagerMock()
    
    init(items: [Item]) {
        self.output = ItemsListViewModelBinding.Output(items: items, isLoading: false)
    }
}
