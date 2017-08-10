//
//  CoordinatorDelegate.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/8/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

/// Coordinator delegate protocol. Used to notify listeners
/// of state changes in the coordinator.
public protocol CoordinatorDelegate: class {
    
    /// Notifies the delegate that the coordinator has been started.
    ///
    /// - Parameter coordinator: Coordinator that was started.
    func coordinatorDidStart(_ coordinator: Coordinator)
    
    /// Notifies the delegate that the coordinator has been stopped.
    ///
    /// - Parameter coordinator: Coordinator that was stopped.
    func coordinatorDidStop(_ coordinator: Coordinator)
    
    /// Notifies the delegate that the coordinator has been paused.
    ///
    /// - Parameter coordinator: Coordinator that was paused.
    func coordinatorDidPause(_ coordinator: Coordinator)
    
    /// Notifies the delegate that the coordinator has been resumed.
    ///
    /// - Parameter coordinator: Coordinator that was resumed.
    func coordinatorDidResume(_ coordinator: Coordinator)
    
}
