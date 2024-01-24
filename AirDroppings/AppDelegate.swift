//
//  AppDelegate.swift
//  AirDroppings
//
//  Created by Johan Bergsee on 2024-01-23.
//  
//

import UIKit
import Logging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }


    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //Get the Main Menu View Controller

        guard let window = UIApplication.shared.firstKeyWindow,
              let mainView = window.rootViewController as? MainMenuViewController else {
            Log.fault(message: "Unable to get mainViewController for URL reception", in: .appState)
            return false
        }


        //Open, parse and treat
        return URLReceiver().openURL(url,
                                     in: mainView)
    }
}


// Another ugly hack just for this test.
extension UIApplication {
    var firstKeyWindow: UIWindow? {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let keyWindow = windowScenes.first?.keyWindow

        return keyWindow
    }
}
