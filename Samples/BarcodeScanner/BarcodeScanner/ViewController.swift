//
//  CameraController.swift
//  BarcodeScanner
//
//  Created by MOSTEFAOUIM on 17/06/2023.
//

import UIKit
import NyrisSDK

class CameraController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codebarLockSwitch: UISwitch!
    @IBOutlet weak var torchlightSwitch: UISwitch!
    
    var cameraManager: CameraManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        cameraManager.stop()
        cameraManager.removeObservers()
        super.viewWillDisappear(animated)
    }
    
    func setupCamera() {
        // Use a builtin camera configuration that works well for barcode scanning.
        let configuration = CameraConfiguration.barcodeScanConfiguration(captureMode: .once,
                                                                         preset: .frame960x540)
        self.cameraManager = CameraManager(configuration: configuration)
        self.cameraManager.authorizationDelegate  = self
        self.cameraManager.codebarScannerDelegate = self
        
        if self.cameraManager.permission != .authorized {
            self.cameraManager.updatePermission()
        } else {
            self.cameraManager.setup()
        }
        
        if cameraManager.permission == .authorized {
            // This is critical for barcode scanning
            // This will observe isRunning of the capture session, which is started in a background queue.
            // once isRunning is changed, we apply the scanView frame to the rect of intrest of the scan meta data output
            // we get the appropriate rect by using `metadataOutputRectConverted` of the preview layer.
            // if you forgot to call addObserver, `metadataOutputRectConverted` will return an empty rect causing the scan to be ignored
            cameraManager.addObservers()
            // Display the preview of the camera along with a rect of intrest for scanning.
            cameraManager.display(on: cameraView, scannerFrame: scanView.frame)
        }
    }

    @IBAction func toggleCodebarLockState(_ sender: Any) {
        
        guard self.cameraManager.isLocked == true else {
            return
        }
        
        self.cameraManager.unlock()
    }
    
    @IBAction func toggleTorchLight(_ sender: UISwitch) {
        self.cameraManager.toggleTorch()
    }
}

extension CameraController : BarcodeScannerDelegate {
    func didCaptureCode(code: String, type: String) {
        self.codeLabel.text = code
    }
    
    func lockDidChange(newValue: Bool) {
        DispatchQueue.main.async {
            self.codebarLockSwitch.isOn = !newValue
        }
    }
}

extension CameraController : CameraAuthorizationDelegate {
    // this is called on main thread.
    func didChangeAuthorization(cameraManager: CameraManager, authorization: SessionSetupResult) {
        switch authorization {
        case .authorized:
            if self.cameraManager.isRunning == false {
                self.cameraManager.setup()
            }
            self.cameraManager.display(on: self.cameraView, scannerFrame: self.scanView.frame)

        default:
            let message = "Please authorize camera access to use this app"
            self.showError(message: message, okActionLogic: { (_) in
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    fatalError("Invalid application setting url")
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
    }
}


