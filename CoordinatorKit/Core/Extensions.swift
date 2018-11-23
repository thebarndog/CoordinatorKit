//
//  Extensions.swift
//  CoordinatorKit-iOS
//
//  Created by Ephraim Russo on 11/23/18.
//  Copyright © 2018 Brendan Conron. All rights reserved.
//

import Foundation

extension NSObject {
    
    @nonobjc public static var classString:String {return "\(self)".components(separatedBy: ".").last!}
}
