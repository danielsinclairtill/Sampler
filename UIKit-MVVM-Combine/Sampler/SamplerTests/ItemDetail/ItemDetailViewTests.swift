//
//  ItemDetailViewTests.swift
//  Sampler
//
//  Created by Daniel on 2026-01-09.
//

import XCTest
@testable import Sampler
import SnapshotTesting

class ItemDetailViewTests: XCTestCase {
    func testStoryDetail() {
        let item = ModelMockData.makeItem(id: "123")
        let user = ModelMockData.makeUser(id: "123")
        let viewModel = MockItemDetailViewModel(item: item, user: user)
        let view = ItemDetailViewController(viewModel: viewModel)
        
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }
    
    func testStoryDetailLongTitle() {
        let item = Item(id: "123",
                        name: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo",
                        ingredients: ["ingredient1"],
                        difficulty: "difficulty1",
                        tags: ["tag1"],
                        userId: "123",
                        image: URL(string: "image_url_123"))
        let user = ModelMockData.makeUser(id: "123")
        let viewModel = MockItemDetailViewModel(item: item, user: user)
        let view = ItemDetailViewController(viewModel: viewModel)
        
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }
    
    func testStoryDetailLongUsername() {
        let item = ModelMockData.makeItem(id: "123")
        let user = User(id: "123",
                        firstName: "first",
                        lastName: "last",
                        username: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo",
                        image: URL(string: "image_url_123"))
        let viewModel = MockItemDetailViewModel(item: item, user: user)
        let view = ItemDetailViewController(viewModel: viewModel)
        
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
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
                        userId: "123",
                        image: URL(string: "image_url_123"))
        let user = ModelMockData.makeUser(id: "123")
        let viewModel = MockItemDetailViewModel(item: item, user: user)
        let view = ItemDetailViewController(viewModel: viewModel)
        
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }

    func testStoryDetailSmallDevice() {
        let item = ModelMockData.makeItem(id: "123")
        let user = ModelMockData.makeUser(id: "123")
        let viewModel = MockItemDetailViewModel(item: item, user: user)
        let view = ItemDetailViewController(viewModel: viewModel)
        
        assertSnapshot(of: view,
                       as: .image(on: .iPhoneSe,
                                  traits: UITraitCollection(userInterfaceStyle: .light)),
                       named: "light mode")
        assertSnapshot(of: view,
                       as: .image(on: .iPhoneSe,
                                  traits: UITraitCollection(userInterfaceStyle: .dark)),
                       named: "dark mode")
    }
    
    func testStoryDetailIPad() {
        let item = ModelMockData.makeItem(id: "123")
        let user = ModelMockData.makeUser(id: "123")
        let viewModel = MockItemDetailViewModel(item: item, user: user)
        let view = ItemDetailViewController(viewModel: viewModel)
        
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

private class MockItemDetailViewModel: ItemDetailViewModelBinding.Contract {
    var input = ItemDetailViewModelBinding.Input()
    var output: ItemDetailViewModelBinding.Output
    var imageManager: any Sampler.ImageManagerContract = SamplerImageManagerMock()
    
    init(item: Item?,
         user: User?) {
        self.output = ItemDetailViewModelBinding.Output(item: item, user: user)
    }
}
