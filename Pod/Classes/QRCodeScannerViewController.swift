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
    var captureSession: AVCaptureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var deviceInput:AVCaptureDeviceInput?
    var metadataOutput:AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    public var highlightView:UIView = UIView()
    
    //MARK: Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        highlightView.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        highlightView.layer.borderColor = UIColor.greenColor().CGColor
        highlightView.layer.borderWidth = 3

        let preset = AVCaptureSessionPresetHigh
        if(captureSession.canSetSessionPreset(preset)) {
            captureSession.sessionPreset = preset
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    override public func viewDidLayoutSubviews() {
        videoPreviewLayer.frame = view.bounds
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(highlightView)
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
             didFailWithError(error)
            return
        }
        
        if let captureInput = deviceInput {
            captureSession.addInput(captureInput)
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        
        videoPreviewLayer.frame = self.view.bounds;
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(videoPreviewLayer)
        view.bringSubviewToFront(highlightView)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startQRScanningSession()
        updateVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (context) -> Void in
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            self.updateVideoOrientation(orientation)
        }, completion: nil)
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    private func updateVideoOrientation(orientation:UIInterfaceOrientation){

        switch orientation {
        case .Portrait :
            videoPreviewLayer.connection?.videoOrientation = .Portrait
            break
        case .PortraitUpsideDown :
            videoPreviewLayer.connection?.videoOrientation = .PortraitUpsideDown
            break
        case .LandscapeLeft :
            videoPreviewLayer.connection?.videoOrientation = .LandscapeLeft
            break
        case .LandscapeRight :
            videoPreviewLayer.connection?.videoOrientation = .LandscapeRight
            break
        default:
            videoPreviewLayer.connection?.videoOrientation = .Portrait
        }
    }
    
    //MARK: QR Code Processing
    
    /**
    * Processes the string content fo the QR code. This method should be overridden
    * in subclasses.
    * @param qrCodeContent The content of the QR code as string.
    * @return A booloean indicating whether the QR code could be processed.
    **/
     public func processQRCodeContent(qrCodeContent:String) -> Bool {
        print(qrCodeContent)
        return false
    }
    
    /**
    * Catch error when the controller is loading. This method can be overriden
    * in subclasses to detect error. Do not dismiss controller immediately.
    * @param error The error object
    **/
    public func didFailWithError(error: NSError) {
        print("Error: \(error.description)")
    }
    
    private func startQRScanningSession(){
        highlightView.frame = CGRectZero
        self.captureSession.startRunning()
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
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.highlightView.alpha = 0
                    }, completion: { (complete) -> Void in
                        if !self.processQRCodeContent(qrCodeContent) {
                            self.highlightView.frame = CGRectZero
                            self.highlightView.alpha = 1
                            self.captureSession.startRunning()
                        }
                    })
                    return
                }
            }
        }
    }
    
}
