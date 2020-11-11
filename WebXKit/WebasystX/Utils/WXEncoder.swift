//
//  WXEncoder.swift
//  WebasystX
//
//  Created by Administrator on 11.11.2020.
//

import Foundation

public enum WXEncoderType {
    case json
    case xml
    case text
}


final class WXEncoder {
    
    // MARK: - Public API methods
    
    public func encode(params: [String:Any], encoding: WXEncoderType) -> Data {
        switch encoding {
        case .json:
            return encode(json: params)
        case .xml:
            return encode(xml: params)
        case .text:
            return encode(text: params)
        }
    }
        
    // MARK: - Utils methods
        
    private func encode(json params:[String:Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
    }
    
    private func encode(xml params:[String:Any]) -> Data {
        return Data() // Write encoding xml
    }
    
    private func encode(text params:[String:Any]) -> Data {
        let keys = params.keys
        
        var textPlain = ""
        for key in keys {
            guard let value = params[key] else  {
               continue
            }
            
        }
        return Data(base64Encoded: textPlain)!
    }
    
    
}
