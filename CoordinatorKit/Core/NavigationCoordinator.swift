//
//  NavigationCoordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

public class NavigationCoordinator: SceneCoordinator<UINavigationController>, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    // MARK: - Coordinators
    
    private(set) public var rootCoordinator: Coordinator?
    
    // MARK: - Navigation State
    
    private var coordinatorStack: Stack<Coordinator> = Stack()
    private var controllerStack: Stack<UIViewController> = Stack()
    
    // MARK: - Initialization
    
    required public init<C>(rootCoordinator: SceneCoordinator<C>) {
        self.rootCoordinator = rootCoordinator
        super.init()
        rootViewController = UINavigationController(rootViewController: rootCoordinator.rootViewController)
        coordinatorStack.push(rootCoordinator)
        controllerStack.push(rootCoordinator.rootViewController)
        configure()
    }
    
    required public init() {
        rootCoordinator = nil
        super.init()
        rootViewController = UINavigationController()
        configure()
    }
    
    public required init(rootViewController: UINavigationController) {
        rootCoordinator = nil
        super.init()
        self.rootViewController = rootViewController
    }
    
    // MARK: - Configuration
    
    private func configure() {
        rootViewController.delegate = self
        rootViewController.interactivePopGestureRecognizer?.delegate = self
        rootViewController.view.backgroundColor = .clear
        rootViewController.automaticallyAdjustsScrollViewInsets = false
    }
    
    /// Set the root coordinator on the navigation coordinator. This can only be used if the 
    /// the root coordinator wasn't set via the initializer already.
    ///
    /// - Parameter coordinator: Root coordinator object.
    public final func setRootCoordinator<C>(_ coordinator: SceneCoordinator<C>) {
        guard coordinatorStack.isEmpty, controllerStack.isEmpty, rootCoordinator == nil else {
            return
        }
        rootCoordinator = coordinator
        rootViewController.pushViewController(coordinator.rootViewController, animated: false)
        coordinatorStack.push(coordinator)
        controllerStack.push(coordinator.rootViewController)
    }
    
    /// Push a coordinator onto the navigation coordinator.
    ///
    /// - Parameters:
    ///   - coordinator: Coordinator to push.
    ///   - animated: Should the push be animated.
    public func pushCoordinator<C>(coordinator: SceneCoordinator<C>, animated: Bool = true) {
        if let topCoordinator = coordinatorStack.peek() {
            pause(coordinator: topCoordinator)
        }
        start(sceneCoordinator: coordinator)
        coordinatorStack.push(coordinator)
        controllerStack.push(coordinator.rootViewController)
    }
    
    /// Pop a coordinator off the navigation stack.
    ///
    /// - Parameter animated: Should the pop be animated.
    public func popCoordinator(animated: Bool = true) {
        guard let coordinator = coordinatorStack.peek(), rootCoordinator != coordinator else { return }
        stop(coordinator: coordinator)
        coordinatorStack.pop()
        controllerStack.pop()
        
        rootViewController.popViewController(animated: animated)
        
        guard let nextCoordinator = coordinatorStack.peek(), nextCoordinator.isPaused else { return }
        resume(coordinator: nextCoordinator)
    }
    
    /// Pops to a given coordinator on the navigation stack.
    ///
    /// - Parameters:
    ///   - coordinator: Coordinator to pop to.
    ///   - animated: Should the pop be animated.
    public func popToCoordinator<C>(coordinator: SceneCoordinator<C>, animated: Bool = true) {
        
        guard children.contains(coordinator) else { return }
        
        while coordinatorStack.peek() != coordinator {
            
            guard let topCoordinator = coordinatorStack.peek() else { continue }
            guard rootCoordinator != topCoordinator else { break }
            stop(coordinator: topCoordinator)
            coordinatorStack.pop()
            controllerStack.pop()
        }
        
        rootViewController.popToViewController(coordinator.rootViewController, animated: animated)
        
        guard let topCoordinator = coordinatorStack.peek() as? SceneCoordinator<C>, topCoordinator.isPaused else { return }
        resume(coordinator: topCoordinator)
    }
    
    /// Pops to the root coordinator on the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: Should the pop be animated.
    public func popToRootCoordinator(animated: Bool = true) {
        
        while coordinatorStack.peek() != rootCoordinator {
            
            guard let topCoordinator = coordinatorStack.peek() else { continue }
            stop(coordinator: topCoordinator)
            coordinatorStack.pop()
            controllerStack.pop()
        }
        
        rootViewController.popToRootViewController(animated: animated)
        
        guard let topCoordinator = coordinatorStack.peek(), topCoordinator == rootCoordinator else { return }
        resume(coordinator: topCoordinator)
    }
    
    /// Hide or show the navigation bar.
    ///
    /// - Parameters:
    ///   - hidden: Should the bar be hidden or shown.
    ///   - animated: Should the tranisition be animated.
    func setNavigationBar(hidden: Bool, animated: Bool = false) {
        rootViewController.setNavigationBarHidden(hidden, animated: animated)
    }
    
    // MARK: - Coordinator
    override public func start() {
        super.start()
        guard let root = rootCoordinator else { return }
        start(coordinator: root)
    }
    
    override public func stop() {
        super.stop()
        coordinatorStack.removeAll()
        controllerStack.removeAll()
        rootCoordinator = nil
    }
    
    override public func coordinatorDidRequestDismissal<C>(_ coordinator: SceneCoordinator<C>) {
        // If the root coordinator is requesting dismisal, we request dismissal from our parent
        if coordinator === rootCoordinator {
            delegate => {
                if let delegate = $0 as? SceneCoordinatorDelegate {
                    delegate.coordinatorDidRequestDismissal(self)
                }
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
    
    // MARK: - Animation
    
    /// Given a child that's being presented on `self`, return the appropriate animator, if any.
    ///
    /// - Parameter child: Child coordinator.
    /// - Returns: Animator.
    override public func animator<C>(forPresentingChild child: SceneCoordinator<C>) -> Animator? {
        return NavigationAnimator()
    }
    
    /// Given a child that's being dismissed on `self`, return the appropriate animator, if any.
    ///
    /// - Parameter child: Child coordinator.
    /// - Returns: Animator.
    override public func animator<C>(forDismissingChild child: SceneCoordinator<C>) -> Animator? {
        return NavigationAnimator()
    }
}
