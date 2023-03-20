//
//  AppDelegate.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/08/07.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        StandardViewModel.shared.fetchData()
        FirebaseApp.configure()
        
        return true
    }
    
}
