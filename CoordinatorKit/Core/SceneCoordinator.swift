//
//  SceneCoordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

/// Coordinator used to represent a scene or a single screen in an application.
/// Scene coordinators have a 1:1 relationship with a view controller that they
/// manage.
open class SceneCoordinator<Controller: UIViewController>: Coordinator {
    
    /// Scene coordinator animator. Used to provide animations/transitions.
    /// You can create your own animator for custom animatons.
    /// By default, `SceneAnimator` is used.
    public var animator: Animator?
    public var rootViewController: Controller
    
    required public init() {
        rootViewController = Controller()
        animator = SceneAnimator()
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
    
    /// Specialized `start` method for scene coordinators. Starts the given child 
    /// scene coordinator and additionally calls the animator, if any, to handle any 
    /// animatons/transitions that need to happen.
    ///
    /// - Parameter sceneCoordinator: Child coordinator to start.
    public final func start<C: UIViewController>(sceneCoordinator: SceneCoordinator<C>) {
        super.start(coordinator: sceneCoordinator)
        animator?.animate(from: self, to: sceneCoordinator)
    }
    
    /// Specialized `stop` method for scene coordinators. Stops the given child
    /// scene coordinator and additionally calls the animator, if any, to handle
    /// dismissal animatons.
    ///
    /// - Parameter sceneCoordinator: Child coordinator to stop.
    public final func stop<C: UIViewController>(sceneCoordinator: SceneCoordinator<C>) {
        super.stop(coordinator: sceneCoordinator)
        animator?.dismiss(coordinator: sceneCoordinator)
    }
    
    // MARK: - SceneCoordinatorDelegate
    
    public func coordinatorDidRequestDismissal<C>(_ coordinator: SceneCoordinator<C>) where C : UIViewController {
        // no-op
    }
    
    
}

extension SceneCoordinator: SceneCoordinatorDelegate {}
