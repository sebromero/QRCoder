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
    let imageSize = CGSize(width: 100, height: 100)
    
    override func setUp() {
        super.setUp()
        qrCodeGenerator = QRCodeGenerator()
    }
    
    func testImageFromString() {
        guard let image = qrCodeGenerator.createImage(value: qrCodeContent, size: imageSize) else { XCTFail(); return }
        XCTAssertNotNil(image)
        XCTAssertEqual(image.size, imageSize)
    }
    
    func testImageWithDifferentCorrectionLevels(){
        var image:QRImage?
        qrCodeGenerator.correctionLevel = .H
        image = qrCodeGenerator.createImage(value: qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        qrCodeGenerator.correctionLevel = .L
        image = qrCodeGenerator.createImage(value: qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        qrCodeGenerator.correctionLevel = .M
        image = qrCodeGenerator.createImage(value: qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
        qrCodeGenerator.correctionLevel = .Q
        image = qrCodeGenerator.createImage(value: qrCodeContent, size: imageSize)
        XCTAssertNotNil(image)
    }
    
}
