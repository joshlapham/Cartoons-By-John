//
//  CameraViewController.swift
//  Kidney John
//
//  Created by Josh Lapham on 24/08/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// TODO: update to use Cocoalumberjack for logging

// MARK: - CameraViewController class
class CameraViewController: UIImagePickerController {
    // MARK: Properties
    var captureSession = AVCaptureSession()
    
    // MARK: - Methods
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Camera", comment: "Title of view")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            print("ERROR! No camera available!")
            return
        }
        
        self.sourceType = UIImagePickerControllerSourceType.Camera
        
//        self.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
        
        let overlayFrame = CGRectMake(50, 100, 150, 150)
//        let overlay = UIView(frame: CGRectMake(50, 100, 50, 50))
        let overlay = UIImageView(frame: overlayFrame)
        overlay.image = UIImage(named: "pal_hotdog")
        overlay.backgroundColor = UIColor.clearColor()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("isDraggingOverlayImage:"))
        self.cameraOverlayView?.addGestureRecognizer(panGesture)
        
        overlay.userInteractionEnabled = true
        self.cameraOverlayView?.userInteractionEnabled = true
        
        self.cameraOverlayView = overlay
        
        // Init camera overlay
//        let cameraDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
//        
//        do {
//            let deviceInput = try AVCaptureDeviceInput(device: cameraDevice)
//            self.captureSession.addInput(deviceInput)
//            
//        } catch let error as NSError {
//            print("ERROR! - \(error.debugDescription)")
//        }
        
        // Add preview overlay
        //        AVCaptureSession *captureSession = <#Get a capture session#>;
        //        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        //        UIView *aView = <#The view in which to present the layer#>;
        //        previewLayer.frame = aView.bounds; // Assume you want the preview layer to fill the view.
        //        [aView.layer addSublayer:previewLayer];
    }
}

// MARK: - Helper methods extension
extension CameraViewController {
    // MARK: Methods
}

// MARK: - Action handler methods
extension CameraViewController {
    // MARK: Methods
    @IBAction func isDraggingOverlayImage(sender: AnyObject?) {
        print("IS DRAGGING OVERLAY IMAGE")
        print(sender)
    }
}