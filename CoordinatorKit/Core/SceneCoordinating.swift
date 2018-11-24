//
//  SceneCoordinating.swift
//  CoordinatorKit-iOS
//
//  Created by Ephraim Russo on 11/23/18.
//  Copyright © 2018 Brendan Conron. All rights reserved.
//

import Foundation
import UIKit

public protocol SceneCoordinating: class {
    
    static func instance() -> Self    
}

extension UIViewController: SceneCoordinating {
    
    public static func instance() -> Self {
        
        return self.init()
    }
}

extension SceneCoordinating where Self : Storyboarded {
    
    public static func instance() -> Self {
        
        return storyboardInstance()
    }
}

extension SceneCoordinating where Self : NibLoadable {
    
    public static func instance() -> Self {
        
        return nibInstance()
    }
}
