//
//  VideoPlayerViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class VideoPlayerViewController: UIViewController {
    @IBOutlet weak var youtubePlayer: YTPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        youtubePlayer.loadWithVideoId("Lv2Q1bAS6mc")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
