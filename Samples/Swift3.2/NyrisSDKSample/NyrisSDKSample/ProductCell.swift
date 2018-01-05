//
//  ProductCell.swift
//  NyrisSDKSample
//
//  Created by MOSTEFAOUI Anas on 05/01/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

class ProductCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.textLabel?.text = ""
        self.detailTextLabel?.text = ""
        self.imageView?.image = nil
    }
    
    func bind(item:OfferInfo) {
        
        guard let imageURL = item.imageInfo?.url, let url = URL(string: imageURL) else {
            return
        }
        
        // async image here
        
        self.textLabel?.text = item.title
        self.detailTextLabel?.text = item.description
    }

}
