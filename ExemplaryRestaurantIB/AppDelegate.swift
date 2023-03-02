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
    
    let shared = StandardViewModel.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        shared.fetchData()
        
        FirebaseApp.configure()
                
        return true
    }
    
}


