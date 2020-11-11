//
//  WXHTTPRequest.swift
//  WebasystX
//
//  Created by Administrator on 11.11.2020.
//

import Foundation

final class WXHTTPRequest {
    
    
    // MARK: - Public API methods
    
    public func makeHTTPOperation() -> WXHTTPOperation {
        return WXHTTPOperation(url: "", tag: "")
    }
    
}
