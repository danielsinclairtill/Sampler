//
//  ItemsListRouter.swift
//  Sampler
//
//  Navigation router for the Items List tab
//

import Foundation
import Combine
import SwiftUI

/// Navigation destinations for the Items List feature
enum ItemsListDestination: Hashable {
    case itemDetail(id: String)
}

/// Router for managing navigation in the Items List tab
class ItemsListRouter: @MainActor NavigationRouter {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to destination: ItemsListDestination) {
        navigationPath.append(destination)
    }
}
