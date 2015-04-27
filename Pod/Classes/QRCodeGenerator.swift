//
//  QRCoder.swift
//
//  Created by Sebastian Hunkeler on 24/04/15.
//  Copyright (c) 2015 IML. All rights reserved.
//

import Foundation
import QuartzCore

#if os(iOS)
import UIKit
public typealias QRColor = UIColor
public typealias QRImage = UIImage
#elseif os(OSX)    
import AppKit
public typealias QRColor = NSColor
public typealias QRImage = NSImage
#endif

@objc
public class QRCodeGenerator {
    
    public var backgroundColor:QRColor = QRColor.whiteColor()
    public var foregroundColor:QRColor = QRColor.blackColor()
    public var correctionLevel:CorrectionLevel = .M
    
    public init(){}
    
    public enum CorrectionLevel : String {
        case L = "L"
        case M = "M"
        case Q = "Q"
        case H = "H"
    }
    
    private func imageWithImageFilter(inputImage:CIImage) -> CIImage {
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter.setDefaults()
        colorFilter.setValue(inputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(CGColor: foregroundColor.CGColor), forKey: "inputColor0")
        colorFilter.setValue(CIColor(CGColor: backgroundColor.CGColor), forKey: "inputColor1")
        return colorFilter.outputImage
    }
    
    public func imageFromString(value:String, size:CGSize) -> QRImage {
        let stringData = value.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: true)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter.setDefaults()
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        
        let outputImage = imageWithImageFilter(qrFilter.outputImage)
        let image = createNonInterpolatedImageFromCIImage(outputImage, size: size)
        return image
    }
    
    
    #if os(iOS)
    private func createNonInterpolatedImageFromCIImage(image:CIImage, size:CGSize) -> QRImage {
        let cgImage = CIContext(options: nil).createCGImage(image, fromRect: image.extent())
        UIGraphicsBeginImageContextWithOptions(size,false,0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    #elseif os(OSX)
    private func createNonInterpolatedImageFromCIImage(image:CIImage, size:CGSize) -> QRImage {
        let cgImage = CIContext().createCGImage(image, fromRect: image.extent())
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        let contextPointer = NSGraphicsContext.currentContext()!.graphicsPort
        let context:CGContextRef
        
        //OSX >= 10.10 supports CGContext property
        if NSGraphicsContext.currentContext()!.respondsToSelector(Selector("CGContext")) {
            context = NSGraphicsContext.currentContext()!.CGContext
        } else {
            context = unsafeBitCast(contextPointer, CGContext.self)
        }
        
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        newImage.unlockFocus()
        return newImage
    }
    #endif
    
}