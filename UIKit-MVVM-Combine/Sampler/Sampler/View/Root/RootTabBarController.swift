//
//  RootTabBarController.swift
//  Sampler
//
//
//

import Foundation
import UIKit
import Combine

class RootUITabBarController: UITabBarController, UITabBarControllerDelegate {
    let tabBarIndexTappedWhileDisplayed = PassthroughSubject<Int, Never>()
    private let tabBarItems: [UINavigationController]
    private var lastSelectedIndex: Int = 0
    private var cancelBag = Set<AnyCancellable>()
    
    required init(tabBarItems: [UINavigationController]) {
        self.tabBarItems = tabBarItems
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewControllers(tabBarItems, animated: false)
        delegate = self
        
        setupDesign()
    }
    
    private func setupDesign() {
        SamplerDesign.shared.$theme
            .sink { [weak self] theme in
                guard let strongSelf = self else { return }
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = theme.attributes.colors.primary()
                strongSelf.tabBar.standardAppearance = appearance
                strongSelf.tabBar.scrollEdgeAppearance = appearance
                strongSelf.tabBar.tintColor = theme.attributes.colors.primaryFill()
            }
            .store(in: &cancelBag)
    }
    
    // MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        guard tabBarController.viewControllers?.indices.contains(tabBarIndex) ?? false else { return }
        
        // if the view controller tab icon has been tapped when it was already open, perform any required logic
        if lastSelectedIndex == tabBarIndex {
            tabBarIndexTappedWhileDisplayed.send(tabBarIndex)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // update the lastSelectedIndex
        lastSelectedIndex = selectedIndex
    }
}
