//
//  TabCoordinator.swift
//  Sampler
//
//
//

import UIKit
import Combine

class TabCoordinator: Coordinator {
    private(set) var parentCoordinator: Coordinator?
    private(set) var children: [Coordinator] = []
    private(set) var navigationController: UINavigationController
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        setupRootUITabBarController()
    }
    
    func presentLoginScreen() {
        let vm = LoginViewModel(environment: SamplerEnvironment.shared,
                                coordinator: self)
        let vc = LoginViewController(viewModel: vm)
        navigationController.viewControllers = [vc]
    }
    
    // MARK: Tabs
    private func setupRootUITabBarController() {
        children = [itemsListTab(), itemSearchTab()]
        let rootViewController = RootUITabBarController(tabBarItems:children.map { $0.navigationController })
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [rootViewController]
        
        // pass any tab bar taps to child coordinators
        rootViewController.tabBarIndexTappedWhileDisplayed
            .sink(receiveValue: { [weak self] tabIndex in
                guard let strongSelf = self,
                      strongSelf.children.indices.contains(tabIndex) else { return }
                let tab = strongSelf.children[tabIndex]
                if let tab = tab as? TabItemCoordinator {
                    tab.tabBarItemTappedWhileDisplayed.send(())
                }
            })
            .store(in: &cancelBag)
    }
    
    private func formatNavigationControllerUI<Controller: UINavigationController>(_ navigationController: Controller) -> Controller {
        SamplerDesign.shared.$theme
            .sink(receiveValue: { theme in
                navigationController.navigationBar.barTintColor = theme.attributes.colors.primary()
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = theme.attributes.colors.primary()
                navigationController.navigationBar.standardAppearance = appearance
                navigationController.navigationBar.scrollEdgeAppearance = appearance
                navigationController.navigationBar.tintColor = theme.attributes.colors.primaryFill()
            })
            .store(in: &cancelBag)
        
        return navigationController
    }
    
    private func itemsListTab() -> ItemsListCoordinator {
        let navigationController = formatNavigationControllerUI(UINavigationController())
        navigationController.tabBarItem = UITabBarItem(title: "com.danielsinclairtill.Sampler.itemsList.title".localized(),
                                                       image: #imageLiteral(resourceName: "ListUnselected"),
                                                       selectedImage: #imageLiteral(resourceName: "List"))
        let coordinator = ItemsListCoordinator(parentCoordinator: self,
                                               navigationController: navigationController)
        coordinator.start()
        return coordinator
    }
    
    private func itemSearchTab() -> ItemSearchCoordinator {
        let navigationController = formatNavigationControllerUI(UINavigationController())
        navigationController.tabBarItem = UITabBarItem(title: "com.danielsinclairtill.Sampler.itemSearch.title".localized(),
                                                       image: .search,
                                                       selectedImage: .searchSelected)
        let coordinator = ItemSearchCoordinator(parentCoordinator: self,
                                                navigationController: navigationController)
        coordinator.start()
        return coordinator
    }
}
