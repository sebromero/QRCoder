//
//  QRCoder.swift
//
//  Created by Sebastian Hunkeler on 24/04/15.
//  Copyright (c) 2015 IML. All rights reserved.
//

import Foundation
import AppKit
import QuartzCore

@objc
public class QRCodeGenerator {
    
    public init(){        
    }
    
    public enum CorrectionLevel : String {
        case L = "L"
        case M = "M"
        case Q = "Q"
        case H = "H"
    }
    
    public func imageFromString(value:String, correctionLevel:CorrectionLevel, size:CGSize) -> NSImage {
        let stringData = value.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: true)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter.setDefaults()
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        let image = createNonInterpolatedImageFromCIImage(qrFilter.outputImage, size: size)
        return image
    }
    
    public func imageFromString(value:String, size:CGSize) -> NSImage {
        return imageFromString(value, correctionLevel: .M, size: size)
    }
    
    private func createNonInterpolatedImageFromCIImage(image:CIImage, size:CGSize) -> NSImage {
        let cgImage = CIContext().createCGImage(image, fromRect: image.extent())
        let image = NSImage(size: size)
        image.lockFocus()
        let contextPointer = NSGraphicsContext.currentContext()!.graphicsPort
        let context = unsafeBitCast(contextPointer, CGContext.self)
        //Once we only support OSX > 10.10 we can use the CGContext property
        //let context = NSGraphicsContext.currentContext().CGContext
        
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        image.unlockFocus()
        return image
    }
    
}