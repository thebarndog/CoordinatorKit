//
//  StackSpec.swift
//  CoordinatorKit
//
//  Created by Brendan Conron on 8/10/17.
//  Copyright © 2017 Brendan Conron. All rights reserved.
//

import Quick
import Nimble
import CoordinatorKit

class StackSpec: QuickSpec {

    override func spec() {
        
        describe("Stack") {
            
            var stack: Stack<Int>!
            
            beforeEach {
                stack = Stack()
            }
            
            it("should push items on the stack") {
                stack.push(1)
                stack.push(2)
                expect(stack.count).to(equal(2))
            }
            
            it("should pop items off the stack") {
                stack.push(1)
                stack.push(2)
                let element = stack.pop()
                expect(element).to(equal(2))
                expect(stack.count).to(equal(1))
            }
            
            it("should remove all items") {
                for i in 0...10 {
                    stack.push(i)
                }
                stack.removeAll()
                expect(stack.isEmpty).to(beTrue())
                expect(stack.count).to(equal(0))
            }
            
            it("should peek at the top element without removing it") {
                stack.push(1)
                let element = stack.peek()
                expect(element).to(equal(1))
                expect(stack.isEmpty).to(beFalse())
                expect(stack.count).to(equal(1))
            }
            
        }
        
    }
}
