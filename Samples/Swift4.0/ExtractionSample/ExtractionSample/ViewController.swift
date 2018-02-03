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
        
        imageView.contentMode = .scaleAspectFit

        let imageFrame = self.imageView.imageFrame
        
        imageView.extractProducts { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                
                let project = box.region.toCGRect()
                let overlay = UIView(frame: project)
                overlay.translatesAutoresizingMaskIntoConstraints = false
                overlay.backgroundColor = .red
                overlay.alpha = 0.4
                self.view.addSubview(overlay)
                break
            }
            guard let last = boxes.first else {
                return
            }
            let imgframe = CGRect(origin: CGPoint.zero, size: image.size)
            var crop = last.region.toCGRect()
            
            crop.origin = CGPoint(x: crop.origin.x - imageFrame.origin.x,
                                  y: crop.origin.y - imageFrame.origin.y)
            
            let projected = crop.projectOn(projectionFrame:imgframe,
                                            from: imageFrame)
            let croped = ImageHelper.crop(image: image, croppingRect: crop)
            let croped2 = ImageHelper.crop(image: image, croppingRect: projected)
            print(1)
        }
    }
    

}

