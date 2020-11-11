//
//  WXHTTPResponse.swift
//  WebasystX
//
//  Created by Administrator on 11.11.2020.
//

import Foundation

final class WXHTTPResponse {
    
    private var result: Data?
    private var error: NSError?
    
    init(result: Data?, error: NSError?) {
        self.result = result
        self.error = error
    }
    
}
