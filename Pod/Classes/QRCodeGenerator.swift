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

@available(OSX 10.9, *)
@objc
public class QRCodeGenerator : NSObject {
    
    public var backgroundColor:QRColor = QRColor.whiteColor()
    public var foregroundColor:QRColor = QRColor.blackColor()
    public var correctionLevel:CorrectionLevel = .M
    
    public enum CorrectionLevel : String {
        case L = "L"
        case M = "M"
        case Q = "Q"
        case H = "H"
    }
    
    private func outputImageFromFilter(filter:CIFilter) -> CIImage? {
        if #available(OSX 10.10, *) {
            return filter.outputImage
        } else {
            return filter.valueForKey("outputImage") as? CIImage ?? nil
        }
    }
    
    private func imageWithImageFilter(inputImage:CIImage) -> CIImage? {
        if let colorFilter = CIFilter(name: "CIFalseColor") {
            colorFilter.setDefaults()
            colorFilter.setValue(inputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(CGColor: foregroundColor.CGColor), forKey: "inputColor0")
            colorFilter.setValue(CIColor(CGColor: backgroundColor.CGColor), forKey: "inputColor1")
            return outputImageFromFilter(colorFilter)
        }
        return nil
    }
    
    public func createImage(value:String, size:CGSize) -> QRImage? {
        let stringData = value.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: true)
        if let qrFilter = CIFilter(name: "CIQRCodeGenerator") {
            qrFilter.setDefaults()
            qrFilter.setValue(stringData, forKey: "inputMessage")
            qrFilter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
            
            guard let filterOutputImage = outputImageFromFilter(qrFilter) else { return nil }
            guard let outputImage = imageWithImageFilter(filterOutputImage) else { return nil }
            return createNonInterpolatedImageFromCIImage(outputImage, size: size)
        }
        return nil
    }
    
    
    #if os(iOS)
    private func createNonInterpolatedImageFromCIImage(image:CIImage, size:CGSize) -> QRImage? {
    
        #if (arch(i386) || arch(x86_64))
        let contextOptions = [kCIContextUseSoftwareRenderer : false]
        #else
        let contextOptions = [kCIContextUseSoftwareRenderer : true]
        #endif
    
        guard let cgImage = CIContext(options: contextOptions).createCGImage(image, fromRect: image.extent) else { return nil }
        UIGraphicsBeginImageContextWithOptions(size,false,0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    #elseif os(OSX)
    private func createNonInterpolatedImageFromCIImage(image:CIImage, size:CGSize) -> QRImage? {
        guard let cgImage = CIContext().createCGImage(image, fromRect: image.extent) else { return nil }
        let newImage = QRImage(size: size)
        newImage.lockFocus()
        let contextPointer = NSGraphicsContext.currentContext()!.graphicsPort
        var context:CGContextRef?
        
        if #available(OSX 10.10, *) {
            //OSX >= 10.10 supports CGContext property
            context = NSGraphicsContext.currentContext()?.CGContext
        } else {
            context = unsafeBitCast(contextPointer, CGContext.self)
        }
    
        guard let graphicsContext = context else { return nil }
        CGContextSetInterpolationQuality(graphicsContext, CGInterpolationQuality.None)
        CGContextDrawImage(graphicsContext, CGContextGetClipBoundingBox(graphicsContext), cgImage)
        newImage.unlockFocus()
        return newImage
    }
    #endif
    
}
