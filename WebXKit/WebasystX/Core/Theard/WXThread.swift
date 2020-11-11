//
//  WXThread.swift
//  WebasystX
//
//  Created by Administrator on 10.11.2020.
//

import Foundation

class WXThread: Thread {
    
    typealias WXThreadBlock = ()->Void
    var done: Bool = true
    private var runloop: RunLoop?
    
    override init() {
        super.init()
    }
    
    override var isExecuting: Bool {
        return !self.done
    }
    
    override func start() {
        self.done = false
        super.start()
    }
        
    override func cancel() {
        self.done = false
        super.cancel()
    }
    
    override func main() {

            var context = CFRunLoopSourceContext(version: 0,
                                                info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()) ,
                                                retain: nil,
                                                release: nil,
                                                copyDescription: nil,
                                                equal: nil,
                                                hash: nil,
                                                schedule: nil,
                                                cancel: nil,
                                                perform: nil)

            let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, CFRunLoopMode.defaultMode)

            repeat {
                let result = CFRunLoopRunInMode(CFRunLoopMode.defaultMode, NSDate.distantFuture.timeIntervalSinceNow, true)

                if (result == .stopped || result == .finished) {
                    self.done = true
                }
            } while (!done)
    }
    
    public func async(_ block: @escaping WXThreadBlock) {
        
        if let currentThread = Thread.current as? WXThread,
           currentThread == self {
            block()
            return
        }
        
        let clouser:@convention(block) () -> Void = block
        self.perform(#selector(_performOnBlock(_:)), on: self, with: clouser, waitUntilDone: false)
    }
    
    public func sync(_ block: @escaping WXThreadBlock) {
        
        if let currentThread = Thread.current as? WXThread,
           currentThread == self {
            block()
            return
        }
              
        let clouser:@convention(block) () -> Void = block
        self.perform(#selector(_performOnBlock(_:)), on: self, with: clouser, waitUntilDone: true)
    }
    
    @objc private func _performOnBlock(_ block: WXThreadBlock?) {
        
        if self.done {
            return
        }
        
        if block != nil {
            autoreleasepool {
                block!()
            }
        }
    }
}
