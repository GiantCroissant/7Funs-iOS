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

    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecipes(onEmpty: {
            dLog("empty local recipes")
            self.fetchMoreRecipes()
        })

//      self.view.makeToast("加入收藏", duration: 10, position: .Top)
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

// MARK: - Recpie Datas
extension RecipesViewController {

    func fetchMoreRecipes() {
        if isFetching {
            return
        }

        dLog("start fetching")

        isFetching = true
        UIUtils.showStatusBarNetworking()

        RecipeManager.sharedInstance.fetchMoreRecipes(
            onComplete: {
                self.loadRecipes()
            },
            onError: { error in
                // TODO: show alert ?
            },
            onFinished: {
                self.isFetching = false
                UIUtils.hideStatusBarNetworking()

                dLog("end fetching")
            }
        )
    }

    func loadRecipes(onEmpty onEmpty: (() -> Void) = {}) {
        UIUtils.showStatusBarNetworking()
        RecipeManager.sharedInstance.loadRecipes() { recipes in
            self.recipes = recipes
            self.tableRecipes.reloadData()
            UIUtils.hideStatusBarNetworking()

            if (recipes.isEmpty) {
                onEmpty()
            }
        }
    }

}

// MARK: - UITableViewDataSource
extension RecipesViewController: UITableViewDataSource {

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

        cell.imgFood.image = ImageLoader.sharedInstance.loadDefaultImage("food_default")

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

// MARK: - UITableViewDelegate
extension RecipesViewController: UITableViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let distFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
        if (distFromBottom <= scrollView.frame.height) {
            fetchMoreRecipes()
        }
    }

}





