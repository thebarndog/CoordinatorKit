//
//  Storyboarded.swift
//  Metal App
//
//  Created by Ephraim Russo on 11/23/18.
//  Copyright © 2018 Metallicus Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol Storyboarded: class {
    
    static var storyboard: UIStoryboard { get }
    
    static var storyboardIdentifier: String { get }
    
    static func storyboardInstance() -> Self
}

extension Storyboarded where Self : NSObject {
    
    public static var storyboardIdentifier: String { return classString }
}

extension Storyboarded where Self : UIViewController {
    
    public static func storyboardInstance() -> Self {
        
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
