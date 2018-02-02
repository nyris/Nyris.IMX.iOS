//
//  ViewController.swift
//  ExtractionSample
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

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
        extractService.extract(from:image , displayFrame: imageView.frame) { (objects, error) in
            guard let boxes = objects else {
                return
            }
            
            for box in boxes {
                
                var project = box.region.toCGRect()
                let overlay = UIView(frame: project)
                overlay.translatesAutoresizingMaskIntoConstraints = false
                overlay.backgroundColor = .red
                overlay.alpha = 0.4
                self.view.addSubview(overlay)
            }
        }
    }
    

}

