//
//  CDQRCodeController.swift
//  B2B-Seller
//
//  Created by 高炼 on 17/6/16.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit
import AVFoundation


@objc protocol CDQRCodeControllerDelegate {
    @objc optional func qrCodeController(_ qrCodeController: CDQRCodeController, captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)
    @objc optional func qrCodeController(_ qrCodeController: CDQRCodeController, getString: String)
}


class AVCapturePreviewView: UIView {
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
    
    override static var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
    //MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
}


class CDQRCodeController: UIViewController {
    weak var delegate: CDQRCodeControllerDelegate?
    
    private (set) lazy var device: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    private var _input: AVCaptureDeviceInput!
    var input: AVCaptureDeviceInput! {
        if _input == nil {
            _input = try? AVCaptureDeviceInput(device: device)
        }
        return _input
    }
    
    private (set) lazy var output = AVCaptureMetadataOutput()
    private (set) lazy var session = AVCaptureSession()
    private (set) lazy var previewView = AVCapturePreviewView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    deinit {
        print("Deinit \(self)")
    }
    
    var cameraFadeInDuration: TimeInterval = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.red
        
        DispatchQueue.global().async { [weak self] in
            guard let this = self else { return }
            this.output.setMetadataObjectsDelegate(this, queue: DispatchQueue.main)
            this.session.addInput(this.input)
            this.session.addOutput(this.output)
            
            this.output.metadataObjectTypes = this.output.availableMetadataObjectTypes.filter { ($0 as? String) != AVMetadataObjectTypeFace }
            this.output.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
            
            this.previewView.layer.session = this.session
            
            this.previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            this.previewView.frame = this.view.bounds
            DispatchQueue.main.async {
                this.previewView.alpha = 0
                this.view.addSubview(this.previewView)
                UIView.animate(withDuration: this.cameraFadeInDuration, animations: {
                    this.previewView.alpha = 1
                })
            }
            this.session.startRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        switch toInterfaceOrientation {
        case .landscapeLeft:
            previewView.layer.connection.videoOrientation = .landscapeLeft
        case .landscapeRight:
            previewView.layer.connection.videoOrientation = .landscapeRight
        case .portrait:
            previewView.layer.connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            previewView.layer.connection.videoOrientation = .portraitUpsideDown
        default: break
        }
    }
    
    func stringDidDetacted(_ string: String) {
    }
    
    //MARK: - Configure
    private func configure() {
        modalTransitionStyle = .coverVertical
    }
}


extension CDQRCodeController: AVCaptureMetadataOutputObjectsDelegate {
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        let getString = (metadataObjects.first as? AVMetadataMachineReadableCodeObject)?.stringValue
        
        if let getString = getString {
            delegate?.qrCodeController?(self, getString: getString)
            stringDidDetacted(getString)
        }
        
        guard delegate != nil else {
            session.stopRunning()
            let alert = UIAlertController(title: nil, message: getString ?? "Found nothing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                self.session.startRunning()
            }))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        delegate?.qrCodeController?(self, captureOutput: captureOutput, didOutputMetadataObjects: metadataObjects, from: connection)
    }
}


extension String {
    var barCode: UIImage? {
        guard let data = self.data(using: .ascii) else { return nil }
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(NSNumber(integerLiteral: 10), forKey: "inputQuietSpace")
        
        guard let ciimage = filter.outputImage else { return nil }
        return UIImage(ciImage: ciimage)
    }
}











































