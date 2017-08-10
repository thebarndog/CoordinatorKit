//
//  Coordinator.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/8/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import UIKit
import Foundation

open class Coordinator: NSObject {
    
    // MARK: - State

    /// <#Description#>
    ///
    /// - active: <#active description#>
    /// - inactive: <#inactive description#>
    /// - paused: <#paused description#>
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
    
    private var children = Set<Coordinator>()
    
    // MARK: - Delegate
    
    public let delegate: MulticastDelegate<CoordinatorDelegate> = MulticastDelegate()
    
    // MARK: - Initialization
    
    public required override init() {
        super.init()
    }
    
    // MARK: - Coordinator Operations
    
    open func start() {
        guard isInactive else { return }
        state = .active
        delegate => { $0.coordinatorDidStart(self) }
    }
    
    open func stop() {
        guard isActive || isPaused else { return }
        state = .inactive
        stopAllChildren()
        delegate => { $0.coordinatorDidStop(self) }
    }
    
    open func pause() {
        guard isActive else { return }
        state = .paused
        pauseAllActiveChildren()
        delegate => { $0.coordinatorDidPause(self) }
    }
    
    open func resume() {
        guard isPaused else { return }
        state = .active
        resumeAllPausedChildren()
        delegate => { $0.coordinatorDidResume(self) }
    }
    
    // MARK: - Querying
    
    public final func hasActiveChildren() -> Bool {
        return children.contains(where: { $0.isActive })
    }
    
    public final func hasChild(_ coordinator: Coordinator) -> Bool {
        return children.contains(coordinator)
    }
    
    // MARK: - Convenience
    
    public final func start<C: Coordinator>(coordinator: C) {
        coordinator.delegate += self
        children.insert(coordinator)
        coordinator.start()
    }
    
    public final func stop<C: Coordinator>(coordinator: C) {
        coordinator.delegate -= self
        children.remove(coordinator)
        coordinator.stop()
    }
    
    public final func pause<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        coordinator.pause()
    }
    
    public final func resume<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        coordinator.resume()
    }
    
    // MARK: - Helpers
    
    private func stopAllChildren() {
        children.forEach {
            if $0.isPaused || $0.isActive {
                $0.stop()
            }
        }
    }
    
    private func pauseAllActiveChildren() {
        children.forEach {
            if $0.isActive {
                $0.pause()
            }
        }
    }
    
    private func resumeAllPausedChildren() {
        children.forEach {
            if $0.isPaused {
                $0.resume()
            }
        }
    }
    
    // MARK: - CoordinatorDelegate
    
    public func coordinatorDidStart(_ coordinator: Coordinator) {
        
    }
    
    public func coordinatorDidStop(_ coordinator: Coordinator) {
        
    }
    
    public func coordinatorDidPause(_ coordinator: Coordinator) {
        
    }
    
    public func coordinatorDidResume(_ coordinator: Coordinator) {
        
    }
    
    // MARK: - SceneCoordinatorDelegate
    
    public func coordinatorDidRequestDismissal<C>(_ coordinator: SceneCoordinator<C>) where C : UIViewController {
        
    }
    
}

extension Coordinator: CoordinatorDelegate {}
extension Coordinator: SceneCoordinatorDelegate {}
