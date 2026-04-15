//
//  ItemDetailViewTests.swift
//  Sampler
//
//  Created by Daniel on 2026-01-09.
//

import XCTest
import Combine
@testable import Sampler
import SnapshotTesting

class ItemDetailViewTests: XCTestCase {
    private var mockEnvironment = SamplerEnvironmentMock()
    
    override func setUp() {
        super.setUp()
        mockEnvironment.reset()
    }
    
    func testStoryDetail() {
        let item = ModelMockData.makeItem(id: "123")
        let viewModel = MockItemDetailViewModel(output: .init(item: item))
        let view = ItemDetailView(viewModel: viewModel)

        assertSnapshotSuite(of: view)
    }
    
    func testStoryDetailLongTitle() {
        let item = Item(id: "123",
                        name: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo",
                        ingredients: ["ingredient1"],
                        difficulty: "difficulty1",
                        tags: ["tag1"],
                        user: ModelMockData.makeUser(id: "1"),
                        image: URL(string: "image_url_123"))
        let viewModel = MockItemDetailViewModel(output: .init(item: item))
        let view = ItemDetailView(viewModel: viewModel)
        
        assertSnapshotSuite(of: view)
    }
    
    func testStoryDetailLongUsername() {
        let item = ModelMockData.makeItem(
            id: "123",
            user: User(id: "123",
                       firstName: "first",
                       lastName: "last",
                       username: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo",
                       image: URL(string: "image_url_123")
                      )
        )
        let viewModel = MockItemDetailViewModel(output: .init(item: item))
        let view = ItemDetailView(viewModel: viewModel)
        
        assertSnapshotSuite(of: view)
    }
    
    func testStoryDetailLongDetail() {
        let item = Item(id: "123",
                        name: "Name",
                        ingredients: ["ingredient1", "ingredient2", "ingredient3", "ingredient4", "ingredient5", "ingredient6",
                                      "ingredient7", "ingredient8", "ingredient9", "ingredient10", "ingredient11", "ingredient12",
                                      "ingredient13", "ingredient14","ingredient15", "ingredient16", "ingredient17", "ingredient18",
                                      "ingredient19", "ingredient20"],
                        difficulty: "difficulty1",
                        tags: ["tag1"],
                        user: ModelMockData.makeUser(id: "1"),
                        image: URL(string: "image_url_123"))
        let viewModel = MockItemDetailViewModel(output: .init(item: item))
        let view = ItemDetailView(viewModel: viewModel)
        
        assertSnapshotSuite(of: view)
    }
}

private class MockItemDetailViewModel: ItemDetailViewModelBinding.Contract {
    var output: Sampler.ItemDetailViewModelBinding.Output
    
    init(output: Sampler.ItemDetailViewModelBinding.Output) {
        self.output = output
    }
    
    func viewDidLoad() async {
        // no op
    }
    
    func tappedPostButton() async {
        // no op
    }
    
    func tappedSaveButton() async {
        // no op
    }
    
    func tappedLikeButton() {
        // no op
    }
}
