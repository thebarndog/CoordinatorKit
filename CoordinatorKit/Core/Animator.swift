//
//  Animator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

/// Coordinator animator protocol. Any object that conforms to this should be able to display and dismiss a coordinator.
public protocol Animator {
    
    func animate<T: UIViewController, U: UIViewController>(from source: SceneCoordinator<T>, to destination: SceneCoordinator<U>)
    func dismiss<T: UIViewController>(coordinator: SceneCoordinator<T>)
    
}

/// Default animator for scene coordinators.
public struct SceneAnimator: Animator {
    
    public func animate<T: UIViewController, U: UIViewController>(from source: SceneCoordinator<T>, to destination: SceneCoordinator<U>) {
        source.rootViewController.present(destination.rootViewController, animated: true, completion: nil)
    }
    
    public func dismiss<T: UIViewController>(coordinator: SceneCoordinator<T>) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
    }
    
}

/// Animator used by the `NavigationCoordinator` class.
public struct NavigationAnimator: Animator {
    
    public func animate<T: UIViewController, U: UIViewController>(from source: SceneCoordinator<T>, to destination: SceneCoordinator<U>) {
        guard let navigationController = source.rootViewController as? UINavigationController else { return }
        navigationController.pushViewController(destination.rootViewController, animated: true)
    }
    
    public func dismiss<T: UIViewController>(coordinator: SceneCoordinator<T>) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
    }
    
}
