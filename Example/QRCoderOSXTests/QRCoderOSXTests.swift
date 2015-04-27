//
//  QRCodeGeneratorExampleTests.swift
//  QRCodeGeneratorExampleTests
//
//  Created by Sebastian Hunkeler on 25/04/15.
//  Copyright (c) 2015 Sebastian Hunkeler. All rights reserved.
//

import Cocoa
import XCTest
import QRCoder

class QRCoderOSXTests: XCTestCase {
    
    var qrCodeGenerator:QRCodeGenerator!
    let qrCodeContent = "Hello World"
    let imageSize = CGSizeMake(100, 100)
    
    override func setUp() {
        super.setUp()
        qrCodeGenerator = QRCodeGenerator()
    }
    
    func testImageFromString() {
        let image = qrCodeGenerator.imageFromString(qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        XCTAssertEqual(image.size, imageSize)
    }
    
    func testImageWithDifferentCorrectionLevel(){
        var image:NSImage?
        image = qrCodeGenerator.imageFromString(qrCodeContent, correctionLevel: .H, size: imageSize)
        XCTAssertNotNil(image)
        image = qrCodeGenerator.imageFromString(qrCodeContent, correctionLevel: .L, size: imageSize)
        XCTAssertNotNil(image)
        image = qrCodeGenerator.imageFromString(qrCodeContent, correctionLevel: .M, size: imageSize)
        XCTAssertNotNil(image)
        image = qrCodeGenerator.imageFromString(qrCodeContent, correctionLevel: .Q, size: imageSize)
        XCTAssertNotNil(image)
    }
    
}
