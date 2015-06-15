//
//  ScannerViewController.swift
//  QRCoderExample
//
//  Created by Sebastian Hunkeler on 27/04/15.
//  Copyright (c) 2015 Sebastian Hunkeler. All rights reserved.
//

import UIKit
import QRCoder

class ScannerViewController : QRCodeScannerViewController {
    
    override func processQRCodeContent(qrCodeContent: String) -> Bool {
        println(qrCodeContent)
        dismissViewControllerAnimated(true, completion: nil)
        return true
    }
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}