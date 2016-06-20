//
//  DispatchAfter.swift
//
//  Created by Nikita Took on 08/04/15.
//  Copyright (c) 2015. All rights reserved.
//
//  inspired by implementation of Matt Neuburg (http://stackoverflow.com/users/341994/matt)
//

import Foundation

public func delay(aDelay:NSTimeInterval, closure: () -> Void) {
    
    delay(aDelay, queue: dispatch_get_main_queue(), closure: closure)
    
}

public func delay(aDelay:NSTimeInterval, queue: dispatch_queue_t!, closure: () -> Void) {
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(aDelay * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, queue, closure)
    
}

public extension Int {
    var second: NSTimeInterval { return NSTimeInterval(self) }
    var seconds: NSTimeInterval { return NSTimeInterval(self) }
    var minute: NSTimeInterval { return NSTimeInterval(self * 60) }
    var minutes: NSTimeInterval { return NSTimeInterval(self * 60) }
    var hour: NSTimeInterval { return NSTimeInterval(self * 3600) }
    var hours: NSTimeInterval { return NSTimeInterval(self * 3600) }
}

public extension Double {
    var second: NSTimeInterval { return self }
    var seconds: NSTimeInterval { return self }
    var minute: NSTimeInterval { return self * 60 }
    var minutes: NSTimeInterval { return self * 60 }
    var hour: NSTimeInterval { return self * 3600 }
    var hours: NSTimeInterval { return self * 3600 }
}