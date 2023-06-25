//
//  UIImage.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import UIKit
import AVFoundation

extension UIImage {
    
    func imageResize(sizeChange: CGSize) -> UIImage? {

        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen

        // Create a Drawing Environment (which will render to a bitmap image, later)
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)

        self.draw(in: CGRect(origin: .zero, size: sizeChange))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

        // Clean up the Drawing Environment (created above)
        UIGraphicsEndImageContext()

        return scaledImage
    }
    
    func resizeToMax(_ bigSize: CGFloat) -> UIImage {
        
        let sideScale = max(self.size.width, self.size.height) / min(self.size.width, self.size.height)
        let smallSize = bigSize / sideScale
        var maxSize: CGSize
        if self.size.width >= self.size.height {
            maxSize = CGSize(width: bigSize, height: smallSize)
        } else {
            maxSize = CGSize(width: smallSize, height: bigSize)
        }
        
        let availableRect = AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: maxSize))
        let targetSize = availableRect.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let resizedImage = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage
    }
    
    var fixedOrientation: UIImage {
        guard imageOrientation != .up else { return self }
        
        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform
                .translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform
                .translatedBy(x: 0, y: size.height).rotated(by: -.pi/2)
        case .upMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard
            let cgImage = cgImage,
            let colorSpace = cgImage.colorSpace,
            let context = CGContext(
                data: nil, width: Int(size.width), height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue
            )
        else { return self }
        context.concatenate(transform)
        
        var rect: CGRect
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        context.draw(cgImage, in: rect)
        return context.makeImage().map { UIImage(cgImage: $0) } ?? self
    }
    
}
