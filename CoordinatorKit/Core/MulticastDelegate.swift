//
//  MulticastDelegate.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/8/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

/// Multicast delegate that allows for multiple listeners.
public struct MulticastDelegate<T> {

    private let delegates: NSHashTable<AnyObject>
    
    public var isEmpty: Bool {
        return delegates.count == 0
    }
    
    /// Default initializer.
    ///
    /// - Parameter strongReferences: Pass true if you want the delegates to be
    /// retained strongly, otherwise the multicast delegate will hold a weak
    /// reference.
    public init(strongReferences: Bool = false) {
        delegates = strongReferences ? NSHashTable() : NSHashTable.weakObjects()
    }
    
    /// Add a delegate.
    ///
    /// - Parameter delegate: Delegate to add.
    public func addDelegate(_ delegate: T) {
        guard !containsDelegate(delegate) else { return }
        delegates.add(delegate as AnyObject)
    }
    
    /// Remove a delegate.
    ///
    /// - Parameter delegate: Delegate to remove.
    public func removeDelegate(_ delegate: T) {
        guard containsDelegate(delegate) else { return }
        delegates.remove(delegate as AnyObject)
    }
    
    /// Invoke a closure on all the delegates.
    ///
    /// - Parameter closure: Closure to invoke.
    public func invoke(_ closure: (T) -> ()) {
        delegates.allObjects.forEach {
            if let delegate = $0 as? T {
                closure(delegate)
            }
        }
    }
    
    /// Query if the multicast delegate contains a given delegate.
    ///
    /// - Parameter delegate: Delegate to query for.
    /// - Returns: Bool, true if the delegate is in the list.
    public func containsDelegate(_ delegate: T) -> Bool {
        return delegates.contains(delegate as AnyObject)
    }
    
    /// Remove all delegates.
    public func removeAll() {
        delegates.removeAllObjects()
    }
    
}

/// Shorthand method for adding a delegate.
///
/// - Parameters:
///   - lhs: Mutlicast delegate object.
///   - rhs: Delegate to add.
public func +=<T>(lhs: MulticastDelegate<T>, rhs: T) {
    lhs.addDelegate(rhs)
}

/// Shorthand method for removing a delegate.
///
/// - Parameters:
///   - lhs: Multicast delegate object.
///   - rhs: Delegate to remove.
public func -=<T>(lhs: MulticastDelegate<T>, rhs: T) {
    lhs.removeDelegate(rhs)
}

precedencegroup MulticastPrecedence {
    associativity: left
    higherThan: TernaryPrecedence
}

infix operator =>: MulticastPrecedence

/// Shorthand operator for invoking closures on the delegates.
///
/// - Parameters:
///   - lhs: Multicast delegate object.
///   - rhs: Closure to invoke.
public func =><T>(lhs: MulticastDelegate<T>, rhs: (T) -> ()) {
    lhs.invoke(rhs)
}
