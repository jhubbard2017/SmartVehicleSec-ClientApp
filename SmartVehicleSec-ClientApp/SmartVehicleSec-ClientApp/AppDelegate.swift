//
//  AppDelegate.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

var server_info = ServerInformation()
var app_utils = AppUtilities()
var server_api = SecurityServerAPI()
var video_streamer = UDPSocketStreamer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    enum appLaunchStatus: Int {
        case firstLaunch = 0, notFirstLaunch
    }
    
    let _LAUNCH_KEY = "LAUNCH_KEY"
    let _SERVER_INFO = "SERVER_INFO"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.save_data()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var initialViewController: UIViewController!
        
        let objects = UserDefaults.standard
        if objects.integer(forKey: _LAUNCH_KEY) == appLaunchStatus.firstLaunch.rawValue {
            let main_sb = UIStoryboard(name: "Main", bundle: nil)
            initialViewController = main_sb.instantiateViewController(withIdentifier: "first_start_view_controller") as! FirstStartController
            
        } else if objects.integer(forKey: _LAUNCH_KEY) == appLaunchStatus.notFirstLaunch.rawValue {
            self.load_data()
            if !server_info.ip_address.isEmpty {
                // Set dashboard view controller
            } else {
                let setup_sb = UIStoryboard(name: "setup", bundle: nil)
                initialViewController = setup_sb.instantiateViewController(withIdentifier: "setup_information_view_controller") as! SetupInformationViewController
            }
        }
        
        if initialViewController != nil {
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Stop session
        self.save_data()
    }
    
    func save_data() {
        /* Saves current app data */
        let server_data = NSKeyedArchiver.archivedData(withRootObject: server_info)
        let encArray: [Data] = [server_data]
        UserDefaults.standard.set(encArray, forKey: _SERVER_INFO)
        UserDefaults.standard.synchronize()
    }
    
    func load_data() {
        /* Loads current data in user defaults */
        if let data: [Data] = UserDefaults.standard.object(forKey: _SERVER_INFO) as? [Data] {
            server_info = NSKeyedUnarchiver.unarchiveObject(with: data[0] as Data) as? ServerInformation ?? ServerInformation()
        }
    }
}

