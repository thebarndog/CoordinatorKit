//
//  SceneCoordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

public typealias SceneCompletionBlock = () -> ()

/// Coordinator used to represent a scene or a single screen in an application.
/// Scene coordinators have a 1:1 relationship with a view controller that they
/// manage.
open class SceneCoordinator<Controller: UIViewController>: Coordinator {
    
    public var rootViewController: Controller
    
    required public init() {
        rootViewController = Controller()
        super.init()
    }
    
    public init(storyboard: UIStoryboard, identifier: String = Controller.classString) {
        rootViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! Controller
        super.init()
    }
    
    public init(nibNamed nibName: String = Controller.classString) {
        
        let items = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        for item in items {
            guard let vc = item as? Controller else { continue }
            rootViewController = vc
            super.init()
            return
        }
        
        rootViewController = Controller()
        super.init()
    }
    
    open override func start() {
        super.start()
        if #available(iOS 9.0, *) {
            rootViewController.loadViewIfNeeded()
        } else {
            rootViewController.loadView()
        }
    }

    // MARK: - Animation

    /// Given a child that's being presented on `self`, return the appropriate animator, if any.
    ///
    /// - Parameter child: Child coordinator.
    /// - Returns: Animator.
    open func animator<C>(forPresentingChild child: SceneCoordinator<C>) -> Animator? {
        return SceneAnimator()
    }

    /// Given a child that's being dismissed on `self`, return the appropriate animator, if any.
    ///
    /// - Parameter child: Child coordinator.
    /// - Returns: Animator.
    open func animator<C>(forDismissingChild child: SceneCoordinator<C>) -> Animator? {
        return SceneAnimator()
    }

    /// Specialized `start` method for scene coordinators. Starts the given child 
    /// scene coordinator and additionally calls the animator, if any, to handle any 
    /// animatons/transitions that need to happen.
    ///
    /// - Note The coordinator uses the animator of the coordinator being started.
    /// - Parameter sceneCoordinator: Child coordinator to start.
    public final func start<C>(sceneCoordinator: SceneCoordinator<C>, completion: SceneCompletionBlock? = nil) {
        super.start(coordinator: sceneCoordinator)
        let animator = self.animator(forPresentingChild: sceneCoordinator)
        animator?.animate(from: self, to: sceneCoordinator, completion: completion)
    }
    
    /// Specialized `stop` method for scene coordinators. Stops the given child
    /// scene coordinator and additionally calls the animator, if any, to handle
    /// dismissal animatons.
    ///
    /// - Note The coordinator uses the animator of the coordinator being stopped.
    /// - Parameter sceneCoordinator: Child coordinator to stop.
    public final func stop<C>(sceneCoordinator: SceneCoordinator<C>, completion: SceneCompletionBlock? = nil) {
        super.stop(coordinator: sceneCoordinator)
        let animator = self.animator(forDismissingChild: sceneCoordinator)
        animator?.dismiss(coordinator: sceneCoordinator, completion: completion)
    }
    
    // MARK: - SceneCoordinatorDelegate
    
    open func coordinatorDidRequestDismissal<C>(_ coordinator: SceneCoordinator<C>) {
        // no-op
    }
    
    
}

extension SceneCoordinator: SceneCoordinatorDelegate {}
