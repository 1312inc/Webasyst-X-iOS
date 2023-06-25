//
//  String.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import Foundation
import Webasyst

extension String {
    
    static var appName: String {
        return .getLocalizedString(withKey: "appName")
    }
    
    static func getLocalizedString(withKey key: String, comment: String? = nil) -> String {
        
        let systemLocalization = NSLocalizedString(key, comment: comment ?? key)
        if systemLocalization != key {
            return systemLocalization
        } else {
            let name = "WebasystLocalization"
            let bundle = bundleForResource(name: name, ofType: "strings")
            let webasystModuleLocalization = NSLocalizedString(key, tableName: name, bundle: bundle, comment: comment ?? key)
            if webasystModuleLocalization != key {
                return webasystModuleLocalization
            } else {
                let webasystLocalization = WebasystApp.getDefaultLocalizedString(withKey: key, comment: comment)
                if webasystLocalization != key {
                    return webasystLocalization
                } else {
                    return key
                }
            }
        }
    }
    
    public func split(every: Int, backwards: Bool = false) -> [String] {
        var result = [String]()
        
        for i in stride(from: 0, to: self.count, by: every) {
            switch backwards {
            case true:
                let endIndex = self.index(self.endIndex, offsetBy: -i)
                let startIndex = self.index(endIndex, offsetBy: -every, limitedBy: self.startIndex) ?? self.startIndex
                result.insert(String(self[startIndex..<endIndex]), at: 0)
            case false:
                let startIndex = self.index(self.startIndex, offsetBy: i)
                let endIndex = self.index(startIndex, offsetBy: every, limitedBy: self.endIndex) ?? self.endIndex
                result.append(String(self[startIndex..<endIndex]))
            }
        }
        
        return result
    }
    
    static var currentInstall: String {
        return UserDefaults.getCurrentInstall()
    }
    
    func transliterate() -> String {
        return self
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .lowercased()
            .replacingOccurrences(of: " ", with: "-") ?? self
    }
    
    func width(by font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: fontAttributes).width
    }
    
    func width(by font: UIFont, additionalWidth: CGFloat) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: fontAttributes).width + additionalWidth
    }
    
    func height(by font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: fontAttributes).height
    }
    
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.textAlignment = .center
        label.font = font
        label.sizeToFit()

        return label.frame.height
     }
}
