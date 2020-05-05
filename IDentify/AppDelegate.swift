//
//  AppDelegate.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 4/25/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //grammar might be weird somewhere. I adjusted commas to make the speech sound more natural and to add some specific stops
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
            VoiceController().read(text: "Hello. This is your first time running SeeForMe. Let me take you on a quick journey through this app main functionality. I designed this app specifically for people with sight disabilities. So it's really easy to use it with specific gestures. Each screen has one button. Other buttons are achievable through vertical swipes. You can also call a command using your voice. Just tap microphone button and say one of four key phrases: 'Read' for reading texts, 'Identify' for identifying colors, 'Text' for looking through saved texts, and 'Color' for looking through saved colors. When you in the specific screen just slide from the edge of the screen to go back. Long tap gesture activates an action and one simple tap stops speaking. In Saved collections screen just swipe on the record to delete it. I hope you will enjoy my app! Peace.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

