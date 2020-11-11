//
//  WXHTTPRequest.swift
//  WebasystX
//
//  Created by Administrator on 11.11.2020.
//

import Foundation

final class WXHTTPRequest {
    
    private var target: WXHTTPTarget!
    
    init(target: WXHTTPTarget) {
        self.target = target
    }
    
    // MARK: - Public API methods
    
    public func makeHTTPOperation() -> WXHTTPOperation {
        
        let baseURL = target.baseURL
        let targetURL = baseURL.appendingPathComponent(target.path)
        let tag = target.tag
        
        let operation = WXHTTPOperation(url: targetURL, tag: tag)
        
        if let urlParams = target.urlParams {
            operation.setURLParamas(params: urlParams)
        }
        
        if let headers = target.headers {
            operation.set(headers: headers)
        }
        
        guard let body = target.body else {
            return operation
        }
        
        switch body {
            case let .requestParametrs(parametrs, encoding):
                operation.set(body: parametrs, encoding: encoding)
            break
        }
        
        return operation
    }
    
}
