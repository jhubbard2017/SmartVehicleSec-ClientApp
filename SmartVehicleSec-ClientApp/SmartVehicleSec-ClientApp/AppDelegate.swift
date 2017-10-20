//
//  AppDelegate.swift
//  SmartVehicleSec-ClientApp
//
//  Created by Jordan Hubbard on 7/25/17.
//  Copyright © 2017 Jordan Hubbard. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let _PASSCODE_KEY = "PASSCODE_KEY"
let _DEVICE_SET_KEY = "DEVICE_SET_KEY"
let objects = UserDefaults.standard

enum authenticationType: Int {
    case passcode = 0, touchID
}
enum appLaunchStatus: Int {
    case firstLaunch = 0, notFirstLaunch
}
enum appLoadingStatus: Int {
    case background = 0, notbackground
}

// Global objects
var api = APIHelperMethods()
var auth_info = AuthInfo()
var app_utils = AppUtilities()
var user_authenticated = false
var is_first_authentication = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Constants: keys to store data
    let _LAUNCH_KEY = "LAUNCH_KEY"
    let _LOADING_KEY = "LOADING_FROM_BACKGROUND"
    let _DATA_KEY = "DATA_INFO"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.sharedManager().enable = true
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
        self.load_data()
        
        if objects.integer(forKey: _LAUNCH_KEY) == appLaunchStatus.firstLaunch.rawValue || (auth_info.host.isEmpty && auth_info.port == 0) {
            // First launch
            let main_sb = UIStoryboard(name: "Main", bundle: nil)
            initialViewController = main_sb.instantiateViewController(withIdentifier: "FirstStartController") as! FirstStartController
            objects.set(appLaunchStatus.notFirstLaunch.rawValue, forKey: _LAUNCH_KEY)
            
        } else if objects.integer(forKey: _LAUNCH_KEY) == appLaunchStatus.notFirstLaunch.rawValue {
    
            // Check if app loaded from background and authentication parameters are loaded from user defaults
            if objects.integer(forKey: _LOADING_KEY) == appLoadingStatus.background.rawValue && user_authenticated {
                // load dashboard (user should be already authenticated on server)
                let dashboard_sb = UIStoryboard(name: "dashboard", bundle: nil)
                initialViewController = dashboard_sb.instantiateViewController(withIdentifier: "DashboardNavigationController") as! UINavigationController
            } else {
                // Go to login view controller (User not authenticated)
                let sb = UIStoryboard(name: "authentication", bundle: nil)
                initialViewController = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
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
        api.logout(email: auth_info.email) { error in
            if (error == nil) {
                objects.set(appLoadingStatus.notbackground.rawValue, forKey: self._LOADING_KEY)
            } else {
                // Error 
            }
        }
        self.save_data()
    }
    
    func save_data() {
        /* Saves current app data */
        let email = NSKeyedArchiver.archivedData(withRootObject: auth_info.email)
        let password = NSKeyedArchiver.archivedData(withRootObject: auth_info.password)
        let host = NSKeyedArchiver.archivedData(withRootObject: auth_info.host)
        let port = NSKeyedArchiver.archivedData(withRootObject: auth_info.port)
        let user_auth = NSKeyedArchiver.archivedData(withRootObject: user_authenticated)
        let is_first_auth = NSKeyedArchiver.archivedData(withRootObject: is_first_authentication)
        let enc_array: [Data] = [email, password, host, port, user_auth, is_first_auth]
        UserDefaults.standard.set(enc_array, forKey: self._DATA_KEY)
        UserDefaults.standard.synchronize()
        print("Successfully saved data.")
    }
    
    func load_data() {
        /* Loads current data in user defaults */
        if let data: [Data] = UserDefaults.standard.object(forKey: self._DATA_KEY) as? [Data] {
            auth_info.email = NSKeyedUnarchiver.unarchiveObject(with: data[0] as Data) as! String
            auth_info.password = NSKeyedUnarchiver.unarchiveObject(with: data[1] as Data) as! String
            auth_info.host = NSKeyedUnarchiver.unarchiveObject(with: data[2] as Data) as! String
            auth_info.port = NSKeyedUnarchiver.unarchiveObject(with: data[3] as Data) as! Int
            user_authenticated = NSKeyedUnarchiver.unarchiveObject(with: data[4] as Data) as! Bool
            is_first_authentication = NSKeyedUnarchiver.unarchiveObject(with: data[5] as Data) as! Bool
            print("Successfully loaded data.")
        }
    }
}

