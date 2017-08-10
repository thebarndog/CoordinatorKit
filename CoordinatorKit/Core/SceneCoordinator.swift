//
//  SceneCoordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

open class SceneCoordinator<Controller: UIViewController>: Coordinator {
    
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
    
    public final func start<C: UIViewController>(sceneCoordinator: SceneCoordinator<C>) {
        super.start(coordinator: sceneCoordinator)
        animator?.animate(from: self, to: sceneCoordinator)
    }
    
    public final func stop<C: UIViewController>(sceneCoordinator: SceneCoordinator<C>) {
        super.stop(coordinator: sceneCoordinator)
        animator?.dismiss(coordinator: sceneCoordinator)
    }
    
    
}
