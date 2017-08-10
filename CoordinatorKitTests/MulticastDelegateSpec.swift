//
//  MulticastDelegateSpec.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/10/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Quick
import Nimble
import CoordinatorKit

private protocol MockProtocol {
    func didReceiveMessage()
}

class MulticastDelegateSpec: QuickSpec {
    
    private class MockListener: MockProtocol {
        var messagesReceived: Int = 0
        
        func didReceiveMessage() {
            messagesReceived += 1
        }
    }
    
    override func spec() {
        
        describe("MulticastDelegate") {
            
            var multicastDelegate: MulticastDelegate<MockListener>!
           
            beforeEach {
                multicastDelegate = MulticastDelegate()
            }
            
            context("when using multiple listeners") {
                
                var mockListener1: MockListener!
                var mockListener2: MockListener!
                
                beforeEach {
                    mockListener1 = MockListener()
                    mockListener2 = MockListener()
                    multicastDelegate += mockListener1
                    multicastDelegate += mockListener2
                }
                
                afterEach {
                    mockListener1 = nil
                    mockListener2 = nil
                }
                
                it("should send a message to each listener") {
                    multicastDelegate => { $0.didReceiveMessage() }
                    expect(mockListener1.messagesReceived).to(equal(1))
                    expect(mockListener2.messagesReceived).to(equal(1))
                }
            }
            
            context("when adding delegates") {
                
                var mockListener: MockListener!
                
                beforeEach {
                    mockListener = MockListener()
                }
                
                it("should contain that delegate") {
                    multicastDelegate += mockListener
                    expect(multicastDelegate.containsDelegate(mockListener)).to(beTrue())
                }
                
            }
            
            context("when removing delegates") {
                
                var mockListener: MockListener!
                
                beforeEach {
                    mockListener = MockListener()
                    multicastDelegate += mockListener
                }
                
                it("should not contain the delegate") {
                    multicastDelegate -= mockListener
                    expect(multicastDelegate.containsDelegate(mockListener)).to(beFalse())
                    expect(multicastDelegate.isEmpty).to(beTrue())
                }
                
            }
            
            afterEach {
                multicastDelegate.removeAll()
            }
            
        }
    }

}
