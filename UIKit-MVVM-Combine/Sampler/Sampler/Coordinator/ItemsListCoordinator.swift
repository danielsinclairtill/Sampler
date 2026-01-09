//
//  ItemsListCoordinator.swift
//  Sampler
//
//
//

import Foundation
import UIKit
import Combine

class ItemsListCoordinator: TabItemCoordinator {
    private(set) var parentCoordinator: Coordinator?
    private(set) var children: [Coordinator] = []
    private(set) var navigationController: UINavigationController
    
    private(set) var tabBarItemTappedWhileDisplayed = PassthroughSubject<Void, Never>()
    
    init(parentCoordinator: Coordinator?,
         navigationController: UINavigationController) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        itemsList()
    }
    
    func itemsList() {
        let vm = ItemsListViewModel(environment: SamplerEnvironment.shared,
                                       coordinator: self)
        let vc = ItemsListViewController(viewModel: vm)
        navigationController.viewControllers = [vc]
    }
    
    func itemDetail(id: String) {
        let vm = ItemDetailViewModel(itemId: id,
                                     environment: SamplerEnvironment.shared,
                                     coordinator: self)
        let vc = ItemDetailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
