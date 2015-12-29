//
//  RecipesViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit
import RealmSwift

class RecipesViewController: UIViewController {

    @IBOutlet weak var tableRecipes: UITableView!

    var isFetching = false
    var recipes = [RecipeUIModel]()
    var token: NotificationToken?

    // if tableview scroll down to bottom

    // => load more recipes ( 10 - 30 ) 

    //

    override func viewDidLoad() {
        super.viewDidLoad()




        // Show Indicator

        // Load recipes from database

        // If count = 0 => ask server for recipes data

            // If got data from server & store to local database

            // Call Load recipes from database again ( X )

            // Load from memory would be better than load from database

        // Else => tableView reload data ( Hide Indicator )



        UIUtils.showStatusBarNetworking()
        RecipeManager.sharedInstance.loadRecipes() { recipes in
//            dLog("recipes count : \(recipes.count)")
            self.recipes = recipes
            self.tableRecipes.reloadData()

            UIUtils.hideStatusBarNetworking()
        }

//      self.view.makeToast("加入收藏", duration: 10, position: .Top)

        let realm = try! Realm()
        token = realm.addNotificationBlock { notification, realm in
            RecipeManager.sharedInstance.loadRecipes() { recipes in
                self.recipes = recipes
                self.tableRecipes.reloadData()
                self.isFetching = false
                UIUtils.hideStatusBarNetworking()
            }
        }
    }

    deinit {
        let realm = try! Realm()
        if let token = token {
            realm.removeNotification(token)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "食譜列表"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showNavigationBar()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)

        self.hideToastIndicator()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""

        let detailVC = segue.destinationViewController as! RecipeDetailViewController
        let row = (sender?.tag)!
        detailVC.recipe = recipes[row]
    }

}

// MARK: - UITableViewDataSource
extension RecipesViewController : UITableViewDataSource {

//    // FIXME: not working
//    @IBAction func onAddButtonClick(sender: UIButton) {
//        let row = sender.tag
//        let recipe = recipes[row]
//        recipe.added = !recipe.added
//        if recipe.added {
//            let image = UIImage(named: "icon_love_m_pink")
//            sender.setImage(image, forState: .Normal)
//
//        } else {
//            let image = UIImage(named: "icon_love_m")
//            sender.setImage(image, forState: .Normal)
//        }
//    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idRecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell

        // FIXME: This line should be delete.
        if (indexPath.row >= recipes.count) {
            return cell
        }

        let recipe = recipes[indexPath.row]
        let imageId = recipe.imageId
        let imageName = recipe.imageName
        let title = recipe.title

        cell.imgFood.image = nil

        // FIXME: should change to row ?
        cell.imgFood.tag = imageId
        cell.btnFood.tag = indexPath.row

        cell.labelTitle.text = title
        cell.btnAddCollection.tag = indexPath.row

        // TODO: finish this logic
        /*
        if recipe.added {
            let image = UIImage(named: "icon_love_m_pink")
            cell.btnAddCollection.setImage(image, forState: .Normal)

        } else {
            let image = UIImage(named: "icon_love_m")
            cell.btnAddCollection.setImage(image, forState: .Normal)
        }
        */

        RecipeManager.sharedInstance.loadFoodImage(imageId, imageName: imageName) { image, imageId, fadeIn in
            if (cell.imgFood.tag == imageId) {
                cell.imgFood.image = image
                cell.imgFood.alpha = 1

                if fadeIn {
                    cell.imgFood.alpha = 0

                    UIView.animateWithDuration(0.3) {
                        cell.imgFood.alpha = 1
                    }

                } else {
                    cell.imgFood.alpha = 1
                }
            }
        }
        return cell
    }
}


extension RecipesViewController: UITableViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if isFetching {
            dLog("is fetching!! do nothing")
            return
        }

        let distFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
        if (distFromBottom <= scrollView.frame.height) {
            isFetching = true
            UIUtils.showStatusBarNetworking()
            RecipeManager.sharedInstance.fetchMoreRecipes()
        }
    }

}





