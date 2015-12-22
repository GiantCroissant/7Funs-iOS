//
//  RecipesViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipesViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var topBackground: UIView!
    @IBOutlet weak var tableRecipes: UITableView!

    var recipes = [RecipeUIModel]()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showNavigationBar()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "食譜列表"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        RecipeManager.sharedInstance.updateCachedRecipesOverviews()

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RecipeManager.sharedInstance.loadRecipes() { recipes in
            self.recipes = recipes

            print("[ RecipesViewController ] : self.recipes count : \(self.recipes.count)")

            self.tableRecipes.reloadData()

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
//        RecipeManager.sharedInstance.fetchMoreRecipes()
        self.view.makeToast("加入收藏", duration: 10, position: .Top)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        navigationItem.title = ""

        let detailVC = segue.destinationViewController as! RecipeDetailViewController
        let row = (sender?.tag)!
        detailVC.recipe = recipes[row]
    }

}

// MARK: - UITableViewDataSource
extension RecipesViewController : UITableViewDataSource {

    // FIXME: not working
    @IBAction func onAddButtonClick(sender: UIButton) {
        let row = sender.tag
        var recipe = recipes[row]
        recipe.added = !recipe.added
        if recipe.added {
            let image = UIImage(named: "icon_love_m_pink")
            sender.setImage(image, forState: .Normal)

        } else {
            let image = UIImage(named: "icon_love_m")
            sender.setImage(image, forState: .Normal)
        }
    }

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
