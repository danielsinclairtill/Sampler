//
//  NavigationRouter.swift
//  Sampler
//
//  Base protocol for SwiftUI navigation routers
//

import Foundation
import SwiftUI

/// Base protocol for SwiftUI navigation routers
/// Each tab/feature maintains its own navigation state and path
protocol NavigationRouter: ObservableObject {
    associatedtype Destination: Hashable
    
    var navigationPath: NavigationPath { get set }
    
    /// Navigate to a specific destination
    func navigate(to destination: Destination)
    
    /// Pop the last item from the navigation stack
    func pop()
    
    /// Reset navigation to root
    func popToRoot()
}

// Default implementations
extension NavigationRouter {
    func pop() {
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
