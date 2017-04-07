//
//  AppDelegate.swift
//  QRCoderExampleOSX
//
//  Created by Sebastian Hunkeler on 27/04/15.
//  Copyright (c) 2015 Sebastian Hunkeler. All rights reserved.
//

import Cocoa
import QRCoder

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageView: NSImageView!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let generator = QRCodeGenerator()
        generator.correctionLevel = .H
        imageView.image = generator.createImage("Hello world!",size: CGSize(width: 200, height: 200))
    }
}
