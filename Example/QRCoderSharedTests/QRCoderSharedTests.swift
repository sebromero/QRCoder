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
    let qrCodeContent = "Hello World! 你好!"
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
    
    func testImageFromURL() {
        let url = URL(string: "http://www.test.com")!
        guard let image = qrCodeGenerator.createImage(url: url, size: imageSize) else { XCTFail(); return }
        let decodedMessage = messageFromImage(image: image)
        XCTAssertEqual(decodedMessage, "http://www.test.com")
    }
    
    func testImageFromData() {
        let data = "hello".data(using: .isoLatin1)!
        guard let image = qrCodeGenerator.createImage(data: data, size: imageSize) else { XCTFail(); return }
        let decodedMessage = messageFromImage(image: image)
        XCTAssertEqual(decodedMessage, "hello")
    }
    
    func testStringFromImage() {
        guard let image = qrCodeGenerator.createImage(value: qrCodeContent, size: imageSize, encoding: .utf8) else { XCTFail(); return }
        let decodedMessage = messageFromImage(image: image)
        XCTAssertEqual(decodedMessage, qrCodeContent)
    }
    
    func messageFromImage(image:QRImage) -> String?{
                
        #if os(iOS)
        let cgImage = image.cgImage!
        #elseif os(OSX)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        #endif
        
        let ciImage = CIImage(cgImage: cgImage)
        XCTAssertNotNil(ciImage)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)
        
        var decodedMessage = ""
        if let detector = detector {
            let features = detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                decodedMessage = feature.messageString!
                if !decodedMessage.isEmpty {
                    return decodedMessage
                }
            }
        }
        return nil
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
