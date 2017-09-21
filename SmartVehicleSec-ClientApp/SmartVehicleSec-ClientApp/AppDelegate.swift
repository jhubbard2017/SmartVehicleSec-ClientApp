//
//  AppDelegate.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit

// Global constants
let _PASSCODE_KEY = "PASSCODE_KEY"

enum authenticationType: Int {
    case passcode = 0, touchID
}

// Global objects
var server_info = ServerInformation()
var app_utils = AppUtilities()
var server_client = SecurityServerAPI()
var device_uuid = UIDevice.current.identifierForVendor?.uuidString
var current_auth_type = authenticationType.passcode.rawValue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // App lanuch status enumeration
    enum appLaunchStatus: Int {
        case firstLaunch = 0, notFirstLaunch
    }
    
    // Constants: keys to store data
    let _LAUNCH_KEY = "LAUNCH_KEY"
    let _SERVER_KEY = "SERVER_INFO"

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
        
        // Todo: Here we will try to run temporary background thread to check if a system breach has been set or if a panic response has been initiated
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var initialViewController: UIViewController!
        
        let objects = UserDefaults.standard
        // Check if this is the first time launching the app or not
        if objects.integer(forKey: _LAUNCH_KEY) == appLaunchStatus.firstLaunch.rawValue {
            print("Apps first launch...")
            // Set initial view controller as first start view controller
            let main_sb = UIStoryboard(name: "Main", bundle: nil)
            initialViewController = main_sb.instantiateViewController(withIdentifier: "first_start_view_controller") as! FirstStartController
            objects.set(appLaunchStatus.notFirstLaunch.rawValue, forKey: _LAUNCH_KEY)
            
        } else if objects.integer(forKey: _LAUNCH_KEY) == appLaunchStatus.notFirstLaunch.rawValue {
            print("Not first launch")
            self.load_data()
            if !server_info.ip_address.isEmpty {
                print("Loading dashboard")
                // Go to dashboard
                let dashboard_sb = UIStoryboard(name: "dashboard", bundle: nil)
                initialViewController = dashboard_sb.instantiateViewController(withIdentifier: "dashboard_navigation_controller") as! UINavigationController
            } else {
                // Go to setup
                print("Loading setup")
                let setup_sb = UIStoryboard(name: "setup", bundle: nil)
                initialViewController = setup_sb.instantiateViewController(withIdentifier: "SetupStartViewController")
            }
        }
        
        if initialViewController != nil {
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        // Todo: Here we will try to run temporary background thread to check if a system breach has been set or if a panic response has been initiated
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Stop session
        self.save_data()
    }
    
    func save_data() {
        /* Saves current app data */
        let ip_address = NSKeyedArchiver.archivedData(withRootObject: server_info.ip_address)
        let port = NSKeyedArchiver.archivedData(withRootObject: server_info.port)
        let enc_array: [Data] = [ip_address, port]
        UserDefaults.standard.set(enc_array, forKey: self._SERVER_KEY)
        UserDefaults.standard.synchronize()
        print("Successfully saved data.")
    }
    
    func load_data() {
        /* Loads current data in user defaults */
        if let data: [Data] = UserDefaults.standard.object(forKey: _SERVER_KEY) as? [Data] {
            server_info.ip_address = NSKeyedUnarchiver.unarchiveObject(with: data[0] as Data) as! String
            server_info.port = NSKeyedUnarchiver.unarchiveObject(with: data[1] as Data) as! Int
            print("Successfullt loaded data.")
        }
    }
}

