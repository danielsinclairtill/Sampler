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

        assertSnapshotSuite(of: view)
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
