//
//  QRCodeScannerViewController.swift
//
//  Created by Sebastian Hunkeler on 18/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import AVFoundation

public class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var orientationObserver:AnyObject?
    var session: AVCaptureSession
    var device:AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var input:AVCaptureDeviceInput?
    var output:AVCaptureMetadataOutput
    var previewLayer:AVCaptureVideoPreviewLayer
    var highlightView:UIView
    
    //MARK: Lifecycle
    
    required public init(coder aDecoder: NSCoder) {
        highlightView = UIView()
        highlightView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin
        highlightView.layer.borderColor = UIColor.greenColor().CGColor
        highlightView.layer.borderWidth = 3
        session = AVCaptureSession()

        let preset = AVCaptureSessionPresetHigh
        if(session.canSetSessionPreset(preset)) {
            session.sessionPreset = preset
        }
        
        output = AVCaptureMetadataOutput()
        previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLayoutSubviews() {
        previewLayer.frame = view.bounds
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(highlightView)
        
        var error:NSError?
        
        input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput
        
        if let captureInput = input {
            session.addInput(captureInput)
        } else {
            println("Error: \(error?.description)")
            return
        }
        
        output.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
        session.addOutput(output)
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        previewLayer.frame = self.view.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer)
        view.bringSubviewToFront(highlightView)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: nil) { (notification) -> Void in
            if let device: UIDevice = notification.object as? UIDevice {
                self.updateVideoOrientation(device.orientation)
            }
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startQRScanningSession()
        updateVideoOrientation(UIDevice.currentDevice().orientation)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if orientationObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(orientationObserver!)
        }
        session.stopRunning()
    }
    
    private func updateVideoOrientation(orientation:UIDeviceOrientation){

        switch orientation {
        case UIDeviceOrientation.Portrait :
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            break
        case UIDeviceOrientation.PortraitUpsideDown :
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            break
        case UIDeviceOrientation.LandscapeLeft :
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            break
        case UIDeviceOrientation.LandscapeRight :
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            break
        default:
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        }
    }
    
    //MARK: QR Code Processing
    
    public func processQRCodeData(qrCodeContent:String) {
        //Override in subclasses
        println(qrCodeContent)
    }
    
    private func startQRScanningSession(delayInSeconds:Double = 0.0){
        highlightView.frame = CGRectZero
        let popTime = dispatch_time(DISPATCH_TIME_NOW, (Int64(delayInSeconds * Double(NSEC_PER_SEC))))
        dispatch_after(popTime, dispatch_get_main_queue()){
            self.session.startRunning()
        }
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        var barCodeObject: AVMetadataMachineReadableCodeObject
        var detectionString:String?
        self.highlightView.frame = highlightViewRect
        
        for metadata in metadataObjects {
            if let metadataObject = metadata as? AVMetadataObject {
                
                if (metadataObject.type == AVMetadataObjectTypeQRCode) {
                    barCodeObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject) as! AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    self.highlightView.frame = highlightViewRect
                    
                    if let machineReadableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                        detectionString = machineReadableObject.stringValue
                    }
                }
                
                if let qrCodeContent = detectionString {
                    session.stopRunning()
                    processQRCodeData(qrCodeContent)
                    return
                }
            }
        }
    }
    
}
