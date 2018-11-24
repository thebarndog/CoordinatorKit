//
//  Animator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

public typealias AnimationCallback = () -> ()

/// Coordinator animator protocol. Any object that conforms to this should be able to display and dismiss a coordinator.
public protocol Animator {

    init()
    
    func animate<T, U>(from source: SceneCoordinator<T>, to destination: SceneCoordinator<U>, completion: AnimationCallback?)
    func dismiss<T>(coordinator: SceneCoordinator<T>, completion: AnimationCallback?)
    
}

/// Default animator for scene coordinators.
public struct SceneAnimator: Animator {

    public init() {}
    
    public func animate<T, U>(from source: SceneCoordinator<T>, to destination: SceneCoordinator<U>, completion: AnimationCallback? = nil) {
        source.rootViewController.present(destination.rootViewController, animated: true, completion: completion)
    }
    
    public func dismiss<T>(coordinator: SceneCoordinator<T>, completion: AnimationCallback? = nil) {
        coordinator.rootViewController.dismiss(animated: true, completion: completion)
    }
    
}

/// Animator used by the `NavigationCoordinator` class.
public struct NavigationAnimator: Animator {

    public init() {}
    
    public func animate<T, U>(from source: SceneCoordinator<T>, to destination: SceneCoordinator<U>, completion: AnimationCallback? = nil) {
        guard let navigationController = source.rootViewController as? UINavigationController else { return }
        navigationController.pushViewController(destination.rootViewController, animated: true)
        completion?()
    }
    
    public func dismiss<T>(coordinator: SceneCoordinator<T>, completion: AnimationCallback? = nil) {
        
        guard let navigationCoordinator = coordinator.parent as? NavigationCoordinator else { return }
        navigationCoordinator.rootViewController.popViewController(animated: true)
    }
}
