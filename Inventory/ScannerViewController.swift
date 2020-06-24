//
//  ScannerViewController.swift
//  Inventory
//
//  Created by Ayman Zaher on 2020-01-03.
//  Copyright © 2020 Ayman Zaher. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var array: [InventoryArray] = []
    @IBOutlet weak var lightB: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code128]
            } else {
                failed()
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        view.bringSubviewToFront(lightB)
            captureSession.startRunning()
        }
        func failed() {
            let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            captureSession = nil
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
            if device.torchMode != .on {
                lightB.setBackgroundImage(UIImage(systemName: "bolt"), for: .normal)
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if (captureSession?.isRunning == true) {
                captureSession.stopRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()
            print(captureSession)
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }

            dismiss(animated: true)
        }

        func found(code: String) {
            print(code)
            array = []
            let digits = code.compactMap { $0.wholeNumberValue }
            if digits[0] == 0 {
                downloadItemsV(urlPath: "http://159.89.119.141/service_veg.php")
                let id = Int("\(digits[1])\(digits[2])")
                updateManger.shared.row = id
                if digits.count >= 4 {
                    if digits[3] == 2 {
                        updateManger.shared.no = 2
                        print("number")
                    } else if digits[3] != 2 {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Invaild Barcode", message: "The barcode you have scanned is not vaild.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    self.captureSession.startRunning()
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                    
                                    
                                }}))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    updateManger.shared.no = 1
                }
            } else if digits[0] == 1 {
               downloadItemsB(urlPath: "http://159.89.119.141/service_boxes.php")
                let id = Int("\(digits[1])\(digits[2])")
                updateManger.shared.row = id
            } else {
                print("Invaild Barcode")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Invaild Barcode", message: "The barcode you have scanned is not vaild.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            self.captureSession.startRunning()
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                            
                            
                        }}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            print(digits)
        }
    func downloadItemsV(urlPath: String) {
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSONV(data!)
            }
            
        }
        
        task.resume()
    }
    
    func parseJSONV(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        
        for i in 0 ..< jsonResult.count {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let name = jsonElement["name"] as? String,
                let quantity = jsonElement["quantity"] as? String,
                let id = jsonElement["id"] as? String, let seconds = jsonElement["seconds"] as? String {
            print("\(id) - \(name) - \(quantity) - \(seconds)")
                let veg = InventoryArray(id: Int(id)!, name: name, quantity: Int(quantity)!,seconds: Int(seconds)!)
                array.append(veg)
            }
            
        }
        DispatchQueue.main.async(execute: { () -> Void in
            updateManger.shared.array = self.array
            if updateManger.shared.array.count - 1 >= updateManger.shared.row {
                print(updateManger.shared.array[updateManger.shared.row])
                let main = UIStoryboard(name: "Main", bundle: nil)
                if #available(iOS 13.0, *) {
                    let vc = main.instantiateViewController(identifier: "veg")
                    self.show(vc, sender: nil)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                print("Invaild Barcode")
                let alert = UIAlertController(title: "Invaild Barcode", message: "The barcode you have scanned is not vaild.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        self.captureSession.startRunning()
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    func downloadItemsB(urlPath: String) {
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSONB(data!)
            }
            
        }
        
        task.resume()
    }
    
    func parseJSONB(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        
        for i in 0 ..< jsonResult.count {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let name = jsonElement["name"] as? String,
                let quantity = jsonElement["quantity"] as? String,
                let id = jsonElement["id"] as? String {
                print("\(id) - \(name) - \(quantity)")
                let box = InventoryArray(id: Int(id)!, name: name, quantity: Int(quantity)!, seconds: 0)
                array.append(box)
                
            }
            
        }
        DispatchQueue.main.async(execute: { () -> Void in
            updateManger.shared.array = self.array
            if updateManger.shared.array.count - 1 >= updateManger.shared.row {
                print(updateManger.shared.array[updateManger.shared.row])
                let main = UIStoryboard(name: "Main", bundle: nil)
                if #available(iOS 13.0, *) {
                    let vc = main.instantiateViewController(identifier: "box")
                    self.show(vc, sender: nil)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                print("Invaild Barcode")
                let alert = UIAlertController(title: "Invaild Barcode", message: "The barcode you have scanned is not vaild.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        self.captureSession.startRunning()
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }

    @IBAction func lightBttn(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.torchMode == .on {
            toggleTorch(on: false)
            lightB.setBackgroundImage(UIImage(systemName: "bolt"), for: .normal)
        } else {
            toggleTorch(on: true)
            lightB.setBackgroundImage(UIImage(systemName: "bolt.fill"), for: .normal)
        }
        
    }
    override var prefersStatusBarHidden: Bool {
            return true
        }

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }
}
