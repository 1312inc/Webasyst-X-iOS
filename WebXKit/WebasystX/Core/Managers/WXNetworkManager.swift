//
//  WXNetworkManager.swift
//  WebasystX
//
//  Created by Administrator on 10.11.2020.
//

import Foundation

typealias WXRequestCompletionBlock = (_ result: WXHTTPResponse?) -> Void
typealias WXRequestProgressBlock = (_ result: Double) -> Void


final class WXNetworkManager {
    
    static let shared = WXNetworkManager()
    
    private var opQueue: WXHTTPOperationQueue!
    @objc private var connectivityThread: Thread!
    
    // MARK: - Init methods

    init() {
        self.opQueue = WXHTTPOperationQueue()
        self.connectivityThread = Thread(target: self, selector:#selector(connectivityThreadMain), object: nil)
    }
    
    // MARK: - Action methods
    
    @objc private func connectivityThreadMain() {
        
        let runloop = RunLoop.current
        
        let done = false
        
        while !done {
            
            runloop.run(until: Date.distantFuture)
        }
        
    }
    
    // MARK: - Public API methods
    
    public func performRequest(request: WXHTTPRequest,
                               progress: WXRequestProgressBlock? = nil,
                               completion: @escaping WXRequestCompletionBlock) {
        
        let operation = request.makeHTTPOperation()
  
        operation.opCompletionBlock = { (result: Data?, sender: Any?) in
            let response = WXHTTPResponse(result: result, error: nil)
            completion(response)
        }
        
        operation.opErrorBlock = {  (error: NSError?, sender: Any?) in
            let response = WXHTTPResponse(result: nil, error: error)
            completion(response)
        }
        
        operation.opProgressBlock = { (result: Double) in
          
            guard let prorgressBlock = progress else {
                return
            }
            
            prorgressBlock(result)
        }
        
        self.opQueue.addOperation(operation)
    }
    
}
