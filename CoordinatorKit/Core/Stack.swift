//
//  Stack.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

/// Simple stack data structure.
public struct Stack<Element> {
    
    private var storage: [Element] = []
    
    public var isEmpty: Bool {
        return storage.isEmpty
    }
    
    public var count: Int {
        return storage.count
    }
    
    public init() {}
    
    mutating public func push(_ element: Element) {
        storage.append(element)
    }
    
    @discardableResult
    mutating public func pop() -> Element? {
        return storage.popLast()
    }
    
    public func peek() -> Element? {
        return storage.last
    }
    
    mutating public func removeAll() {
        storage.removeAll()
    }
    
}
