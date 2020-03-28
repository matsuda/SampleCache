//
//  AppDelegate.swift
//  SampleCache
//
//  Created by Kosuke Matsuda on 2020/03/15.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var cacheDir = DiskCache.cacheDirectory()
        print("cacheDir >>>", cacheDir)
        cacheDir = (DiskCache.cacheDirectory() as NSString).appendingPathComponent("com.github.matsuda.SampleCache")
        try? FileManager.default.removeItem(atPath: cacheDir)
        return true
    }
}

