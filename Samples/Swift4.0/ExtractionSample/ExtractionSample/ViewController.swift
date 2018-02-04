//
//  ViewController.swift
//  ExtractionSample
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imageViewCenter: UIImageView!
    @IBOutlet weak var imageViewAspectFit: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    var extractService:ProductExtractionService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         extractService = ProductExtractionService()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let image = imageView.image else {
            return
        }

        imageView.contentMode = .center
        imageView.extractProducts { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                self.addOverlay(box: box)
            }
            guard let last = boxes.first else {
                return
            }
            let crop = ImageHelper.crop(from: self.imageView,
                                        extractedObject: last)
            print(1)
        }
        
        imageView.match { (offers, error) in
            //
        }
        
        imageViewAspectFit.extractProducts { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                self.addOverlay(box: box)
            }
            guard let last = boxes.first else {
                return
            }
            let crop = ImageHelper.crop(from: self.imageViewAspectFit,
                                        extractedObject: last)
            print(1)
        }
        
        imageViewCenter.extractProducts { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                self.addOverlay(box: box)
            }
            print(1)
        }
    }
    
    func addOverlay(box:ExtractedObject) {
        let boxRect = box.region.toCGRect()
        let overlay = UIView(frame: boxRect)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = .red
        overlay.alpha = 0.4
        self.view.addSubview(overlay)
    }

}

