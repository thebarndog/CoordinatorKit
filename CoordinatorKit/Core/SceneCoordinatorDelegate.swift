//
//  SceneCoordinatorDelegate.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

/// Delegate protocol for SceneCoordinators. It extends the `CoordinatorDelegate` protocol.
public protocol SceneCoordinatorDelegate: CoordinatorDelegate {
    
    /// Notifies the delegate that the given coordinator is requesting to be dismissed.
    ///
    /// - Parameter coordinator: Coordinator that's requesting dismissal.
    func coordinatorDidRequestDismissal<C: UIViewController>(_ coordinator: SceneCoordinator<C>)
    
}
