//
//  LinkFriendViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class LinkFriendViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var url = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NSURLRequest(URL: NSURL(string: url)!)
        webView.loadRequest(request)
    }

}

extension LinkFriendViewController: UIWebViewDelegate {

    func webViewDidStartLoad(webView: UIWebView) {
        UIUtils.showStatusBarNetworking()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        UIUtils.hideStatusBarNetworking()
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIUtils.hideStatusBarNetworking()

        dLog("error = \(error) ")
    }

}