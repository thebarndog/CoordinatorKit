//
//  MulticastDelegate.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/8/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

public struct MulticastDelegate<T> {

    private let delegates: NSHashTable<AnyObject>
    
    public var isEmpty: Bool {
        return delegates.count == 0
    }
    
    init(strongReferences: Bool = false) {
        delegates = strongReferences ? NSHashTable() : NSHashTable.weakObjects()
    }
    
    func addDelegate(_ delegate: T) {
        guard !containsDelegate(delegate) else { return }
        delegates.add(delegate as AnyObject)
    }
    
    func removeDelegate(_ delegate: T) {
        guard containsDelegate(delegate) else { return }
        delegates.remove(delegate as AnyObject)
    }
    
    public func invoke(_ closure: (T) -> ()) {
        delegates.allObjects.forEach {
            if let delegate = $0 as? T {
                closure(delegate)
            }
        }
    }
    
    public func containsDelegate(_ delegate: T) -> Bool {
        return delegates.contains(delegate as AnyObject)
    }
    
}

public func +=<T>(lhs: MulticastDelegate<T>, rhs: T) {
    lhs.addDelegate(rhs)
}

public func -=<T>(lhs: MulticastDelegate<T>, rhs: T) {
    lhs.removeDelegate(rhs)
}

precedencegroup MulticastPrecedence {
    associativity: left
    higherThan: TernaryPrecedence
}

infix operator =>: MulticastPrecedence

public func =><T>(lhs: MulticastDelegate<T>, rhs: (T) -> ()) {
    lhs.invoke(rhs)
}
