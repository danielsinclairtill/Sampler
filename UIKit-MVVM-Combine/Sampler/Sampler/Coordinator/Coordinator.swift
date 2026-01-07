//
//  Coordinator.swift
//  Sampler
//
//
//

import Foundation
import UIKit
import Combine

protocol Coordinator {
    var parentCoordinator: Coordinator? { get }
    var children: [Coordinator] { get }
    var navigationController : UINavigationController { get }
    
    func start()
}

protocol TabItemCoordinator: Coordinator {
    /// The tab bar item for this navigation path has been tapped while it is already selected.
    var tabBarItemTappedWhileDisplayed: PassthroughSubject<Void, Never> { get }
}
