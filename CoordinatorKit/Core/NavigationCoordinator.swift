//
//  NavigationCoordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

public final class NavigationCoordinator: SceneCoordinator<UINavigationController>, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    private(set) public var rootCoordinator: Coordinator?
    
    private var coordinatorStack: Stack<Coordinator> = Stack()
    private var controllerStack: Stack<UIViewController> = Stack()
    
    // MARK: - Initialization
    
    required public init<C: UIViewController>(rootCoordinator: SceneCoordinator<C>) {
        self.rootCoordinator = rootCoordinator
        super.init()
        animator = NavigationAnimator()
        rootViewController = UINavigationController(rootViewController: rootCoordinator.rootViewController)
        coordinatorStack.push(rootCoordinator)
        controllerStack.push(rootCoordinator.rootViewController)
        configure()
    }
    
    required public init() {
        rootCoordinator = nil
        super.init()
        animator = NavigationAnimator()
        rootViewController = UINavigationController()
        configure()
    }
    
    private func configure() {
        rootViewController.delegate = self
        rootViewController.interactivePopGestureRecognizer?.delegate = self
        rootViewController.view.backgroundColor = .white
        rootViewController.automaticallyAdjustsScrollViewInsets = false
    }
    
    public func setRootCoordinator<C: UIViewController>(_ coordinator: SceneCoordinator<C>) {
        guard coordinatorStack.isEmpty, controllerStack.isEmpty, rootCoordinator == nil else {
            return
        }
        rootCoordinator = coordinator
        rootViewController.pushViewController(coordinator.rootViewController, animated: false)
        coordinatorStack.push(coordinator)
        controllerStack.push(coordinator.rootViewController)
    }
    
    public func pushCoordinator<C: UIViewController>(coordinator: SceneCoordinator<C>, animated: Bool = true) {
        if let topCoordinator = coordinatorStack.peek() {
            pause(coordinator: topCoordinator)
        }
        start(sceneCoordinator: coordinator)
        coordinatorStack.push(coordinator)
        controllerStack.push(coordinator.rootViewController)
    }
    
    public func popCoordinator(animated: Bool = true) {
        guard let coordinator = coordinatorStack.peek() as? SceneCoordinator, rootCoordinator != coordinator else { return }
        stop(sceneCoordinator: coordinator)
        coordinatorStack.pop()
        controllerStack.pop()
        guard let topCoordinator = coordinatorStack.peek(), topCoordinator.isPaused else { return }
        resume(coordinator: topCoordinator)
    }
    
    func setNavigationBar(hidden: Bool, animated: Bool = false) {
        rootViewController.setNavigationBarHidden(hidden, animated: animated)
    }
    
    // MARK: - Coordinator
    override public func start() {
        super.start()
        if let root = rootCoordinator {
            start(coordinator: root)
        }
    }
    
    override public func stop() {
        super.stop()
        coordinatorStack.removeAll()
        controllerStack.removeAll()
        rootViewController.dismiss(animated: true, completion: nil)
    }
    
    override public func coordinatorDidRequestDismissal<C: UIViewController>(_ coordinator: SceneCoordinator<C>) {
        // If the root coordinator is requesting dismisal, we request dismissal from our parent
        if coordinator === rootCoordinator {
            delegate => {
                ($0 as? SceneCoordinatorDelegate)?.coordinatorDidRequestDismissal(self)
            }
        } else {
            popCoordinator(animated: true)
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // While the view controller that was just shown does not equal the one on the top of the stack
        // go through the stack until you find it
        while controllerStack.peek() != viewController {
            guard let coordinator = coordinatorStack.peek() else {
                break
            }
            stop(coordinator: coordinator)
            controllerStack.pop()
            coordinatorStack.pop()
            if let topCoordinator = coordinatorStack.peek(), controllerStack.peek() == viewController, topCoordinator.isPaused {
                resume(coordinator: topCoordinator)
                break
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Necessary to get the child navigation controller’s interactive pop gesture recognizer to work.
        return true
    }
    
}
