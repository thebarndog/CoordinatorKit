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

extension SceneCoordinating where Self : NSObject {
    
    public static func instance() -> Self { return self.init()
    }
}

extension SceneCoordinating where Self : (NSObject & Storyboarded) {
    
    public static func instance() -> Self {
        
        return storyboardInstance()
    }
}

extension SceneCoordinating where Self : (NSObject & NibLoadable) {
    
    public static func instance() -> Self {
        
        return nibInstance()
    }
}

extension UIViewController: SceneCoordinating { }
