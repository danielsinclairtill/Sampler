//
//  ItemSearchRouter.swift
//  Sampler
//
//  Navigation router for the Item Search tab
//

import Foundation
import Combine
import SwiftUI

/// Navigation destinations for the Item Search feature
enum ItemSearchDestination: Hashable {
    case itemDetail(id: String)
}

/// Router for managing navigation in the Item Search tab
@MainActor
class ItemSearchRouter: @MainActor NavigationRouter {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to destination: ItemSearchDestination) {
        navigationPath.append(destination)
    }
}
