//
//  TabCoordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/11/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit

open class TabCoordinator: SceneCoordinator<UITabBarController> {
    
    private let coordinators: [Coordinator]
    private let controllers: [UIViewController]
    
    public var selectedIndex: Int = 0 {
        didSet {
            switchTab(toIndex: selectedIndex, fromOldIndex: oldValue)
        }
    }
    
    public init<A: UIViewController>(_ coordinator: SceneCoordinator<A>) {
        coordinators = [coordinator]
        controllers = [coordinator.rootViewController]
        super.init()
        commonInit()
    }
    
    public init<A: UIViewController,
         B: UIViewController>(_ a: SceneCoordinator<A>, _ b: SceneCoordinator<B>) {
        coordinators = [a, b]
        controllers = [a.rootViewController, b.rootViewController]
        super.init()
        commonInit()
    }
    
    public init<A: UIViewController,
         B: UIViewController,
         C: UIViewController>(_ a: SceneCoordinator<A>, _ b: SceneCoordinator<B>, _ c: SceneCoordinator<C>) {
        coordinators = [a, b, c]
        controllers = [a.rootViewController, b.rootViewController, c.rootViewController]
        super.init()
        commonInit()
    }
    
    public init<A: UIViewController,
         B: UIViewController,
         C: UIViewController,
         D: UIViewController>(_ a: SceneCoordinator<A>, _ b: SceneCoordinator<B>, _ c: SceneCoordinator<C>, _ d: SceneCoordinator<D>) {
        coordinators = [a, b, c, d]
        controllers = [a.rootViewController, b.rootViewController, c.rootViewController, d.rootViewController]
        super.init()
        commonInit()
    }
    
    public init<A: UIViewController,
         B: UIViewController,
         C: UIViewController,
         D: UIViewController,
         E: UIViewController>(_ a: SceneCoordinator<A>, _ b: SceneCoordinator<B>, _ c: SceneCoordinator<C>, _ d: SceneCoordinator<D>, _ e: SceneCoordinator<E>) {
        coordinators = [a, b, c, d, e]
        controllers = [a.rootViewController, b.rootViewController, c.rootViewController, d.rootViewController, e.rootViewController]
        super.init()
        commonInit()
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    private func commonInit() {
        rootViewController.setViewControllers(controllers, animated: false)
        rootViewController.delegate = self
    }
    
    override open func start() {
        super.start()
        guard selectedIndex < coordinators.count else { return }
        let coordinator = coordinators[selectedIndex]
        start(coordinator: coordinator)
    }
    
    // MARK: - Helpers
    
    private func switchTab(toIndex index: Int, fromOldIndex oldIndex: Int) {
        guard index != oldIndex else { return }
        guard index < coordinators.count else { return }
        let destinationCoordinator = coordinators[index]
        let sourceCoordinator = coordinators[oldIndex]
        pause(coordinator: sourceCoordinator)
        if destinationCoordinator.isInactive {
            start(coordinator: destinationCoordinator)
        } else if destinationCoordinator.isPaused {
            resume(coordinator: destinationCoordinator)
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = controllers.index(of: viewController) else { return }
        selectedIndex = index
    }
    
}

extension TabCoordinator: UITabBarControllerDelegate {}
