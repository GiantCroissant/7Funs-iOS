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
    var isEnablingHorizontalScroll = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NSURLRequest(URL: NSURL(string: url)!)
        webView.loadRequest(request)
        webView.scrollView.delegate = self
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


extension LinkFriendViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        lockHorizontalScrolling(scrollView)
    }

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        isEnablingHorizontalScroll = scale - 1 > 0.01
    }

    func lockHorizontalScrolling(scrollView: UIScrollView) {
        if isEnablingHorizontalScroll {
            return
        }

        if (scrollView.contentOffset.x > 0 || scrollView.contentOffset.x < 0){
            scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y)
        }
    }

}

