//
//  MainViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var btnShowInfos: UIButton!
    @IBOutlet weak var btnVideos: UIButton!
    @IBOutlet weak var btnRecipes: UIButton!
    @IBOutlet weak var btnCollections: UIButton!
    @IBOutlet weak var btnQandA: UIButton!
    @IBOutlet weak var btnLinks: UIButton!
    @IBOutlet weak var btnBonus: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setImageToScaleAspectFill(btnShowInfos)
        setImageToScaleAspectFill(btnVideos)
        setImageToScaleAspectFill(btnRecipes)
        setImageToScaleAspectFill(btnCollections)
        setImageToScaleAspectFill(btnQandA)
        setImageToScaleAspectFill(btnLinks)
        setImageToScaleAspectFill(btnBonus)
    }

    func setImageToScaleAspectFill(button: UIButton) {
        button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
