//
//  QRCoderOSXTests.swift
//  QRCoderOSXTests
//
//  Created by Sebastian Hunkeler on 25/04/15.
//  Copyright (c) 2015 Sebastian Hunkeler. All rights reserved.
//

import XCTest
import QRCoder

class QRCoderSharedTests: XCTestCase {
    
    var qrCodeGenerator:QRCodeGenerator!
    let qrCodeContent = "Hello World"
    let imageSize = CGSizeMake(100, 100)
    
    override func setUp() {
        super.setUp()
        qrCodeGenerator = QRCodeGenerator()
    }
    
    func testImageFromString() {
        let image = qrCodeGenerator.createImage(qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        XCTAssertEqual(image.size, imageSize)
    }
    
    func testImageWithDifferentCorrectionLevels(){
        var image:QRImage?
        qrCodeGenerator.correctionLevel = .H
        image = qrCodeGenerator.createImage(qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        qrCodeGenerator.correctionLevel = .L
        image = qrCodeGenerator.createImage(qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        qrCodeGenerator.correctionLevel = .M
        image = qrCodeGenerator.createImage(qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        qrCodeGenerator.correctionLevel = .Q
        image = qrCodeGenerator.createImage(qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
    }
    
}
