//
//  AppDelegate.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/8/6.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        window?.rootViewController = DPTabBarController()
        
        
        // Override point for customization after application launch.
        return true
    }
}

