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
    var captureSession: AVCaptureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var deviceInput:AVCaptureDeviceInput?
    var metadataOutput:AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    public var highlightView:UIView = UIView()
    
    //MARK: Lifecycle
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        highlightView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin
        highlightView.layer.borderColor = UIColor.greenColor().CGColor
        highlightView.layer.borderWidth = 3

        let preset = AVCaptureSessionPresetHigh
        if(captureSession.canSetSessionPreset(preset)) {
            captureSession.sessionPreset = preset
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(captureSession) as! AVCaptureVideoPreviewLayer
    }
    
    override public func viewDidLayoutSubviews() {
        videoPreviewLayer.frame = view.bounds
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(highlightView)
        
        var error:NSError?
        
        deviceInput = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error) as? AVCaptureDeviceInput
        
        if let captureInput = deviceInput {
            captureSession.addInput(captureInput)
        } else {
            println("Error: \(error?.description)")
            return
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        
        videoPreviewLayer.frame = self.view.bounds;
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(videoPreviewLayer)
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
        captureSession.stopRunning()
    }
    
    private func updateVideoOrientation(orientation:UIDeviceOrientation){

        switch orientation {
        case UIDeviceOrientation.Portrait :
            videoPreviewLayer.connection?.videoOrientation = .Portrait
            break
        case UIDeviceOrientation.PortraitUpsideDown :
            videoPreviewLayer.connection?.videoOrientation = .PortraitUpsideDown
            break
        case UIDeviceOrientation.LandscapeLeft :
            videoPreviewLayer.connection?.videoOrientation = .LandscapeRight
            break
        case UIDeviceOrientation.LandscapeRight :
            videoPreviewLayer.connection?.videoOrientation = .LandscapeLeft
            break
        default:
            videoPreviewLayer.connection?.videoOrientation = .Portrait
        }
    }
    
    //MARK: QR Code Processing
    
    public func processQRCodeContent(qrCodeContent:String) {
        //Override in subclasses
        println(qrCodeContent)
    }
    
    private func startQRScanningSession(delayInSeconds:Double = 0.0){
        highlightView.frame = CGRectZero
        let popTime = dispatch_time(DISPATCH_TIME_NOW, (Int64(delayInSeconds * Double(NSEC_PER_SEC))))
        dispatch_after(popTime, dispatch_get_main_queue()){
            self.captureSession.startRunning()
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
                    barCodeObject = videoPreviewLayer.transformedMetadataObjectForMetadataObject(metadataObject) as! AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    self.highlightView.frame = highlightViewRect
                    
                    if let machineReadableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                        detectionString = machineReadableObject.stringValue
                    }
                }
                
                if let qrCodeContent = detectionString {
                    captureSession.stopRunning()
                    processQRCodeContent(qrCodeContent)
                    return
                }
            }
        }
    }
    
}
