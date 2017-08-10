//
//  CoordinatorSpec.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/10/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Quick
import Nimble
import CoordinatorKit

class CoordinatorSpec: QuickSpec {

    override func spec() {
        
        describe("Coordinator") {
            
            var coordinator: Coordinator!
            beforeEach {
                coordinator = Coordinator()
            }
            
            context("when started") {
                
                it("should be active") {
                    coordinator.start()
                    expect(coordinator.isActive).to(beTrue())
                    expect(coordinator.isInactive).to(beFalse())
                    expect(coordinator.isPaused).to(beFalse())
                }
                
            }
            
            context("when active and then stopped") {
                
                beforeEach {
                    coordinator.start()
                    coordinator.stop()
                }
                
                it("should be inactive") {
                    expect(coordinator.isInactive).to(beTrue())
                    expect(coordinator.isActive).to(beFalse())
                    expect(coordinator.isPaused).to(beFalse())
                }
                
            }
            
        }
        
    }
    
}
