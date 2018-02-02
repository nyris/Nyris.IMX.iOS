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
        
        let visibleRect = AVMakeRect(aspectRatio: image.size, insideRect:imageView.frame)

        print(imageView.frame)
        print(imageView.image?.size)
        print(visibleRect)
        let imageRect = CGRect(origin: imageView.center, size: visibleRect.size)
        extractService.extract(from:image , displayFrame: imageRect) { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                
                let overlay = UIView(frame: box.region.toCGRect())
                overlay.backgroundColor = .red
                overlay.alpha = 0.4
                self.view.addSubview(overlay)
            }
        }
    }
    

}

