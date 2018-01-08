//
//  ViewController.swift
//  NyrisSDKSample
//
//  Created by MOSTEFAOUI Anas on 05/01/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK
// needed for position
import CoreLocation

class ViewController: CameraController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var darkView: UIView!
    
    var matchingService:ImageMatchingService!
    var offerList:[Offer] = []
    
    // handle UI loading indicators (dark layer and loading indicator)
    var isLoading:Bool = false {
        didSet(oldValue) {
            DispatchQueue.main.async {
                self.darkView.isHidden = self.isLoading == false
                self.captureButton.isEnabled = self.isLoading == false
                self.isLoading == true ?
                    self.activityIndicator.startAnimating() :
                    self.activityIndicator.stopAnimating()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        matchingService = ImageMatchingService()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // resume the camera capture
        if self.cameraManager.isRunning == false {
            self.cameraManager.start()
        }
    }
    // MARK: - UI Actions
    override func processCapturedImage(image: UIImage?) {
        // pause the camera
        self.cameraManager.stop()
        self.isLoading = true
        
        self.process(image: image) { [weak self] (offersList, error) in
            self?.isLoading = false
            DispatchQueue.main.async {
                self?.captureButton.isEnabled = true
                // reset button state to enable next capture
                guard let offers = offersList, offers.isEmpty == false, error == nil else {
                    if self?.cameraManager.isRunning == false {
                        self?.cameraManager.start()
                    }
                    return
                }
                
                self?.goToResultPage()
            }
        }
    }
    
    /// get products similar to the one in the picture
    func process(image:UIImage?,
                 position:CLLocation? = nil,
                 isSemanticSearch:Bool = false,
                 completion:@escaping ( _ offerList:[Offer]?, _ error:Error?) -> Void) {
        
        // the image may be invalid
        guard let validImage = image else {
            self.showError(message: "Invalid Image")
            return
        }
        
        self.matchingService
            .getSimilarProducts(image: validImage, position: nil, isSemanticSearch: isSemanticSearch) { [weak self] (result, error) in
                self?.handleResponse(products: result, error: error, completion: completion)
        }
    }
    
    /// handle image matching service response
    func handleResponse(products:[Offer]?, error:Error?,
                        completion:( _ offerList:[Offer]?, _ error:Error?) -> Void) {
        
        guard let validProducts = products, error == nil else {
            self.showError(title:"Error",
                                 message: "Unknown error")
            completion(nil, error)
            return
        }
        
        self.offerList = validProducts
        completion(products, error)
    }
    
    func goToResultPage() {
        self.performSegue(withIdentifier: "navigateToProductListSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateToProductListSegue",
            let controller = segue.destination as? ResultController {
            controller.items = self.offerList
        }
    }
}

