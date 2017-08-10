//
//  CoordinatorDelegate.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/8/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

public protocol CoordinatorDelegate: class {
    
    func coordinatorDidStart(_ coordinator: Coordinator)
    
    func coordinatorDidStop(_ coordinator: Coordinator)
    
    func coordinatorDidPause(_ coordinator: Coordinator)
    
    func coordinatorDidResume(_ coordinator: Coordinator)
    
}
