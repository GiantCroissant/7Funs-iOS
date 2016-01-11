//
//  AppDelegate.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/4/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import RealmSwift

func bundlePath(path: String) -> String? {
    let resourcePath = NSBundle.mainBundle().resourcePath as NSString?
    return resourcePath?.stringByAppendingPathComponent(path)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        handleDbMigration()
        setupCustomNaviationBar()

//        return true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func setupCustomNaviationBar() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navAppearance.shadowImage = UIImage()
        navAppearance.translucent = true
        navAppearance.backgroundColor = UIColor.clearColor()
        navAppearance.tintColor = UIColor.whiteColor()
        navAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    func handleDbMigration() {
//        let defaultPath = Realm.Configuration.defaultConfiguration.path!
//        let defaultParentPath = (defaultPath as NSString).stringByDeletingLastPathComponent
//        
//        // copy over old data files for migration
//        if let v0Path = bundlePath("default-v0.realm") {
//            do {
//                try NSFileManager.defaultManager().removeItemAtPath(defaultPath)
//                try NSFileManager.defaultManager().copyItemAtPath(v0Path, toPath: defaultPath)
//            } catch {}
//        }
//        
//        // define a migration block
//        // you can define this inline, but we will reuse this to migrate realm files from multiple versions
//        // to the most current version of our data model
//        let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
//            if oldSchemaVersion < 1 {
//                migration.enumerate(Person.className()) { oldObject, newObject in
//                    if oldSchemaVersion < 1 {
//                        // combine name fields into a single field
//                        let firstName = oldObject!["firstName"] as! String
//                        let lastName = oldObject!["lastName"] as! String
//                        newObject?["fullName"] = "\(firstName) \(lastName)"
//                    }
//                }
//            }
//            if oldSchemaVersion < 2 {
//                migration.enumerate(Person.className()) { oldObject, newObject in
//                    // give JP a dog
//                    if newObject?["fullName"] as? String == "JP McDonald" {
//                        let jpsDog = migration.create(Pet.className(), value: ["Jimbo", "dog"])
//                        let dogs = newObject?["pets"] as? List<MigrationObject>
//                        dogs?.append(jpsDog)
//                    }
//                }
//            }
//            print("Migration complete.")
//        }
//        
//        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 3, migrationBlock: migrationBlock)
//        
//        // print out all migrated objects in the default realm
//        // migration is performed implicitly on Realm access
//        print("Migrated objects in the default Realm: \(try! Realm().objects(Person))")
//        
//        /
//        // Migrate a realms at a custom paths
//        //
//        if let v1Path = bundlePath("default-v1.realm"), v2Path = bundlePath("default-v2.realm") {
//            let realmv1Path = (defaultParentPath as NSString).stringByAppendingPathComponent("default-v1.realm")
//            let realmv2Path = (defaultParentPath as NSString).stringByAppendingPathComponent("default-v2.realm")
//            
//            let realmv1Configuration = Realm.Configuration(path: realmv1Path, schemaVersion: 3, migrationBlock: migrationBlock)
//            let realmv2Configuration = Realm.Configuration(path: realmv2Path, schemaVersion: 3, migrationBlock: migrationBlock)
//            
//            do {
//                try NSFileManager.defaultManager().removeItemAtPath(realmv1Path)
//                try NSFileManager.defaultManager().copyItemAtPath(v1Path, toPath: realmv1Path)
//                try NSFileManager.defaultManager().removeItemAtPath(realmv2Path)
//                try NSFileManager.defaultManager().copyItemAtPath(v2Path, toPath: realmv2Path)
//            } catch {}
//            
//            // migrate realms at realmv1Path manually, realmv2Path is migrated automatically on access
//            migrateRealm(realmv1Configuration)
//            
//            // print out all migrated objects in the migrated realms
//            let realmv1 = try! Realm(configuration: realmv1Configuration)
//            print("Migrated objects in the Realm migrated from v1: \(realmv1.objects(Person))")
//            let realmv2 = try! Realm(configuration: realmv2Configuration)
//            print("Migrated objects in the Realm migrated from v2: \(realmv2.objects(Person))")
//        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
         let loginManager: FBSDKLoginManager = FBSDKLoginManager()
         loginManager.logOut()
    }
}

