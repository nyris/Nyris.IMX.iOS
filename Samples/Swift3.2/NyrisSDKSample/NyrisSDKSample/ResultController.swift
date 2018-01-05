//
//  ResultController.swift
//  NyrisSDKSample
//
//  Created by MOSTEFAOUI Anas on 05/01/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

class ResultController: UITableViewController {

    var items:[OfferInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath) as? ProductCell else {
            fatalError("no cell for the given reuse id")
        }
        cell.bind(item: item)
        return cell
    }

}
