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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        imageView.extractProducts { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                self.addOverlay(box: box)
            }
            
            guard let first = boxes.first else {
                return
            }
            
            let croppedImag = ImageHelper.crop(from: self.imageView,
                                               extractedObject: first)
            print(1)
        }
        
        imageViewAspectFit.extractProducts { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                self.addOverlay(box: box)
            }
            guard let first = boxes.first else {
                return
            }
            let croppedImag = ImageHelper.crop(from: self.imageViewAspectFit,
                                               extractedObject: first)
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
        
        imageView.match { (offers, error) in
            // offers
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

