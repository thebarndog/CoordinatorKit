//
//  SceneCoordinatorDelegate.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/9/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Foundation

public protocol SceneCoordinatorDelegate: CoordinatorDelegate {
    
    func coordinatorDidRequestDismissal<C: UIViewController>(_ coordinator: SceneCoordinator<C>)
    
}
