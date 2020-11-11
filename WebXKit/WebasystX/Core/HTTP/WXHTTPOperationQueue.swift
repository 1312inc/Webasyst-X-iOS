//
//  WXHTTPOperationQueue.swift
//  WebasystX
//
//  Created by Administrator on 10.11.2020.
//

import Foundation

public class WXHTTPOperationQueue: OperationQueue {
    public func cancelAndWaitAllOperationsFinished(cancel :Bool,completion: @escaping (()->Void)) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            while ( (self?.operationCount)! > 0) {
                if cancel {
                    self?.cancelAllOperations()
                }
                
                self?.waitUntilAllOperationsAreFinished()
            }
            
            completion()
        }
    }
}
