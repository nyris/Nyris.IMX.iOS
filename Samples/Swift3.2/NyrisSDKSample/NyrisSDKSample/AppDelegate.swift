//
//  AppDelegate.swift
//  NyrisSDKSample
//
//  Created by MOSTEFAOUI Anas on 05/01/2018.
//  Copyright © 2018 Nyris. All rights reserved.
//

import UIKit
import NyrisSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
        
        return true
    }

}

