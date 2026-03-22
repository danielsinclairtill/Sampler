//
//  TabRouter.swift
//  Sampler
//
//

import Foundation
import Combine

/// Coordinator for managing root-level tab navigation
class TabRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    @PublishedObject var itemsListRouter = ItemsListRouter()
    @PublishedObject var itemSearchRouter = ItemSearchRouter()
    
    /// Reset a tab's navigation stack when it's re-tapped
    func resetTabIfSelected(_ tabIndex: Int) {
        if selectedTab == tabIndex {
            switch tabIndex {
            case 0:
                itemsListRouter.popToRoot()
            case 1:
                itemSearchRouter.popToRoot()
            default:
                break
            }
        }
    }
}
