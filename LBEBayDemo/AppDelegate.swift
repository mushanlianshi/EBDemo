//
//  AppDelegate.swift
//  camera
//
//  Created by liu bin on 2023/12/26.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static let playerSuperView: UIView = UIView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initAppearance()
        initLaunchController()
        return true
    }
    
    
    private func initLaunchController(){
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = UINavigationController(rootViewController: EBHomeViewController())
    }
    
    
    private func initAppearance(){
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = .white
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.blt.threeThreeBlackColor()]
            appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.blt.threeThreeBlackColor()]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().isTranslucent = false
        }
    }


}

