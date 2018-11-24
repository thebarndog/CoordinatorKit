//
//  Coordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/8/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

/// Base coordinator class. Represents a coordinator object which is primary
/// used as a flow coordinator for your application.
open class Coordinator: NSObject {
    
    // MARK: - State

    /// The current state of the given coordinator.
    ///
    /// - active: The coordinator is currently running and/or is performing active work.
    /// - inactive: The coordinator is not performing any work and is considered dormant.
    /// - paused: The coordinator was active but was paused. Coordinators in this state should throttle their work.
    public enum State {
        case active, inactive, paused
    }
    
    private(set) public var state: State = .inactive

    public var isActive: Bool {
        return state == .active
    }
    
    public var isInactive: Bool {
        return state == .inactive
    }
    
    public var isPaused: Bool {
        return state == .paused
    }
    
    // MARK: - Children
    
    private(set) var children = Set<Coordinator>()
    
    private(set) weak var parent: Coordinator?
    
    // MARK: - Delegate
    
    /// Coordinator multicast delegate to allow for multiple listeners.
    public let delegate: MulticastDelegate<CoordinatorDelegate> = MulticastDelegate()
    
    // MARK: - Initialization
    
    public required override init() {
        super.init()
    }
    
    // MARK: - Coordinator Operations
    
    /// Start the coordinator and become active.
    /// Use this method to begin work.
    open func start() {
        guard isInactive else { return }
        state = .active
        delegate => { $0.coordinatorDidStart(self) }
    }
    
    /// Stop the coordinator and become inactive.
    /// Use this method to stop any and all work i.e. save state.
    open func stop() {
        guard isActive || isPaused else { return }
        state = .inactive
        stopAllChildren()
        delegate => { $0.coordinatorDidStop(self) }
    }
    
    /// Pause an active coordinator.
    /// Use this method to throttle work.
    open func pause() {
        guard isActive else { return }
        state = .paused
        pauseAllActiveChildren()
        delegate => { $0.coordinatorDidPause(self) }
    }
    
    /// Resume a paused coordinator.
    /// Use this method to resume any currently paused work.
    open func resume() {
        guard isPaused else { return }
        state = .active
        resumeAllPausedChildren()
        delegate => { $0.coordinatorDidResume(self) }
    }
    
    // MARK: - Querying
    
    /// Asks the coordinator if it has any children that are in the given state.
    ///
    /// - Parameter state: Coordinator state.
    /// - Returns: Bool, true if any children coordinators are in the given state.
    public func hasChildren(inState state: State) -> Bool {
        return !children.filter { $0.state == state }.isEmpty
    }
    
    /// Query for the number of children that are currently in the given state.
    ///
    /// - Parameter state: Coordinator state.
    /// - Returns: Number of children that are in the given state.
    public final func numberOfChildren(inState state: State) -> Int {
        return children.filter { $0.state == state }.count
    }
    
    /// Query the coordinator if it contains the given coordinator among it's children.
    ///
    /// - Parameter coordinator: Coordinator to check for.
    /// - Returns: Bool, true if the given coordinator is in the set of children.
    public final func hasChild(_ coordinator: Coordinator) -> Bool {
        return children.contains(coordinator)
    }
    
    
    /// Query for the number of children, regardless of current state.
    ///
    /// - Returns: Number of children.
    public final func numberOfChildren() -> Int {
        return children.count
    }
    
    // MARK: - Child Coordinators
    
    /// Start a child coordinator.
    ///
    /// This method should *always* be used rather than calling `coordinator.start()` 
    /// directly. Starting a child coordinator has two important side-effects:
    /// 1) The parent coordinator adds itself as a delegate of the child.
    /// 2) The coordinator gets inserted into the set of children.
    ///
    /// - Parameter coordinator: Coordinator to start.
    public final func start<C: Coordinator>(coordinator: C) {
        guard !hasChild(coordinator) else { return }
        coordinator.delegate += self
        children.insert(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    /// Stops the given child coordinator.
    ///
    /// This method *must* be used instead of calling `coordinator.stop()` directly.
    /// Stopping a child coordinator has two important side-effects:
    /// 1) The parent removes itself as a delegate.
    /// 2) The coordinator is removed from the list of children.
    ///
    /// - Parameter coordinator: Coordinator to stop.
    public final func stop<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        coordinator.delegate -= self
        children.remove(coordinator)
        coordinator.parent = nil
        coordinator.stop()
    }
    
    /// Pauses the given child coordinator.
    ///
    /// This method is a wrapper function for convenience and consistency.
    ///
    /// - Parameter coordinator: Coordinator to pause.
    public final func pause<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        guard !coordinator.isPaused else { return }
        coordinator.pause()
    }
    
    /// Resumes the given child coordinator.
    ///
    /// This method is a wrapper function for convenience and consistency.
    ///
    /// - Parameter coordinator: Coordinator to resume.
    public final func resume<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        guard coordinator.isPaused else { return }
        coordinator.resume()
    }
    
    // MARK: - Helpers
    
    /// Stop all the children of the coordinator.
    private func stopAllChildren() {
        children.forEach {
            if $0.isPaused || $0.isActive {
                stop(coordinator: $0)
            }
        }
    }
    
    /// Pauses all currently active children.
    private func pauseAllActiveChildren() {
        children.forEach {
            if $0.isActive {
                pause(coordinator: $0)
            }
        }
    }
    
    /// Resumes all children that are paused.
    private func resumeAllPausedChildren() {
        children.forEach {
            if $0.isPaused {
                resume(coordinator: $0)
            }
        }
    }
    
    // MARK: - CoordinatorDelegate
    
    open func coordinatorDidStart(_ coordinator: Coordinator) {
        
    }
    
    open func coordinatorDidStop(_ coordinator: Coordinator) {
        
    }
    
    open func coordinatorDidPause(_ coordinator: Coordinator) {
        
    }
    
    open func coordinatorDidResume(_ coordinator: Coordinator) {
        
    }
    
}

extension Coordinator: CoordinatorDelegate {}
