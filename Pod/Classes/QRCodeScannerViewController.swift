//
//  QRCodeScannerViewController.swift
//
//  Created by Sebastian Hunkeler on 18/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import AVFoundation

open class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var captureSession: AVCaptureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice? = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var deviceInput:AVCaptureDeviceInput?
    var metadataOutput:AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    open var highlightView:UIView = UIView()
    
    //MARK: Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        highlightView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        highlightView.layer.borderColor = UIColor.green.cgColor
        highlightView.layer.borderWidth = 3

        let preset = AVCaptureSessionPresetHigh
        if(captureSession.canSetSessionPreset(preset)) {
            captureSession.sessionPreset = preset
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    override open func viewDidLayoutSubviews() {
        videoPreviewLayer.frame = view.bounds
    }
    
    override open func viewDidLoad()
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
        
        metadataOutput.setMetadataObjectsDelegate(self, queue:DispatchQueue.main)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        
        videoPreviewLayer.frame = self.view.bounds;
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(videoPreviewLayer)
        view.bringSubview(toFront: highlightView)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startQRCodeScanningSession()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            let orientation = UIApplication.shared.statusBarOrientation
            self.updateVideoOrientation(orientation)
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    fileprivate func updateVideoOrientation(_ orientation:UIInterfaceOrientation){

        switch orientation {
        case .portrait :
            videoPreviewLayer.connection?.videoOrientation = .portrait
            break
        case .portraitUpsideDown :
            videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
            break
        case .landscapeLeft :
            videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            break
        case .landscapeRight :
            videoPreviewLayer.connection?.videoOrientation = .landscapeRight
            break
        default:
            videoPreviewLayer.connection?.videoOrientation = .portrait
        }
    }
    
    //MARK: QR Code Processing
    
    /**
    * Processes the string content fo the QR code. This method should be overridden
    * in subclasses.
    * @param qrCodeContent The content of the QR code as string.
    * @return A booloean indicating whether the QR code could be processed.
    **/
     open func processQRCodeContent(_ qrCodeContent:String) -> Bool {
        print(qrCodeContent)
        return false
    }
    
    /**
    * Catch error when the controller is loading. This method can be overriden
    * in subclasses to detect error. Do not dismiss controller immediately.
    * @param error The error object
    **/
    open func didFailWithError(_ error: NSError) {
        print("Error: \(error.description)")
    }
    
    /**
     * Starts the scanning session using the built in camera.
     **/
    open func startQRCodeScanningSession(){
        updateVideoOrientation(UIApplication.shared.statusBarOrientation)
        highlightView.frame = CGRect.zero
        captureSession.startRunning()
    }
    
    /**
     Stops the scanning session
     */
    open func stopQRCodeScanningSession(){
        captureSession.stopRunning()
        highlightView.frame = CGRect.zero
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    
    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRect.zero
        var barCodeObject: AVMetadataMachineReadableCodeObject
        var detectionString:String?
        self.highlightView.frame = highlightViewRect
        
        for metadata in metadataObjects {
            if let metadataObject = metadata as? AVMetadataObject {
                
                if (metadataObject.type == AVMetadataObjectTypeQRCode) {
                    barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject) as! AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    self.highlightView.frame = highlightViewRect
                    
                    if let machineReadableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                        detectionString = machineReadableObject.stringValue
                    }
                }
                
                if let qrCodeContent = detectionString {
                    captureSession.stopRunning()
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.highlightView.alpha = 0
                    }, completion: { (complete) -> Void in
                        if !self.processQRCodeContent(qrCodeContent) {
                            self.highlightView.frame = CGRect.zero
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
