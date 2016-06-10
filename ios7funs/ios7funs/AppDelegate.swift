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
  let loadRecipesInBackgroundTimeInterval: NSTimeInterval = 5
  let loadVideoInBackgroundTimeInterval: NSTimeInterval = 5
  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    startBackgroundLoadRecipes()
    startBackgroundLoadVideos()
    setupCustomNaviationBar()
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func startBackgroundLoadVideos() {
    NSTimer.scheduledTimerWithTimeInterval(loadVideoInBackgroundTimeInterval,
      target: self,
      selector: #selector(AppDelegate.loadVideosInBackground),
      userInfo: nil,
      repeats: true
    )
  }

  func startBackgroundLoadRecipes() {
    NSTimer.scheduledTimerWithTimeInterval(loadRecipesInBackgroundTimeInterval,
      target: self,
      selector: #selector(AppDelegate.loadRecipesInBackground),
      userInfo: nil,
      repeats: true
    )
  }

  func loadRecipesInBackground() {
    RecipeManager.sharedInstance.fetchMoreRecipes()
  }

  func loadVideosInBackground() {
    VideoManager.sharedInstance.fetchMoreVideos()
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

