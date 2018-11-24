//
//  NibLoadable.swift
//  CoordinatorKit-iOS
//
//  Created by Ephraim Russo on 11/23/18.
//  Copyright © 2018 Brendan Conron. All rights reserved.
//

import Foundation
import UIKit

public protocol NibLoadable: class {
    
    static var nibName: String { get }
    
    static func nibInstance() -> Self
}

extension NibLoadable where Self : NSObject {

    public static var nibName: String { return classString }
}

extension NibLoadable where Self : UIViewController {
    
    public static func nibInstance() -> Self {
        
        let items = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        for item in items {
            guard let vc = item as? Self else { continue }
            return vc
        }

        return self.init()
    }
}

extension NibLoadable where Self : UIView {
    
    public static func nibInstance() -> Self {
        
        let items = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        for item in items {
            guard let vc = item as? Self else { continue }
            return vc
        }
        
        return self.init()
    }
}
