//
//  CameraController.swift
//  NyrisSDKSample
//
//  Created by MOSTEFAOUI Anas on 05/01/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//
import UIKit
import NyrisSDK

class CameraController: UIViewController {
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    var cameraManager: CameraManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
    }
    
    // MARK: - setup
    func setupCamera() {
        
        let configuration = CameraConfiguration.codebarScanConfiguration(captureMode: .once,
                                                                         preset: .frame960x540)
        self.cameraManager =  CameraManager(configuration: configuration)
        self.cameraManager.authorizationDelegate  = self
        
        if self.cameraManager.permission != .authorized {
            self.cameraManager.updatePermission()
        } else {
            self.cameraManager.setup()
            self.cameraManager.display(on: self.cameraView)
        }
        
    }
    
    // MARK: - UI Actions
    @IBAction func captureAction(_ sender: UIButton) {
        
        guard self.cameraManager.permission == .authorized else {
            self.cameraManager.updatePermission()
            return
        }
        
        // saving the picture may take some time, lock to avoid spam the button
        sender.isEnabled =  false
        
        // this method will save, rotate, and resize the picture
        // this actions should be available as parameters
        self.cameraManager.takePicture { [weak self] image in
            self?.processCapturedImage(image: image)
        }
    }
    
    /// Process captured image, this should be implemented by the child class
    /// This method should reset the capture button to its original enabled state to be able to capture other pictures
    /// - Parameter image: image captured by the camera
    func processCapturedImage(image:UIImage?) {
        fatalError("processCapturedImage is not implemented in child class")
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
            self.cameraManager.display(on: self.cameraView)
        default:
            let message = "Please authorize camera access to use this app"
            self.showError(message: message, okActionLogic: { (_) in
                guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                    fatalError("Invalid application setting url")
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
    }
}


extension UIViewController {
    /// generic alert view
    func showError(title:String = "Error", message:String, okActionLogic:((UIAlertAction?) -> Void)? = nil) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action) in
                okActionLogic?(action)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

