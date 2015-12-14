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
    
//    let bag = DisposeBag()

    func scrollViewDidScroll(scrollView: UIScrollView) {

        /*
        print("y = \(scrollView.contentOffset.y)")
        let y = scrollView.contentOffset.y
        if (y > 0) {
            topBackground.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(1 - ((100 - y) / 100))
        }
        */

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Show navigation bar.
        self.navigationController?.navigationBarHidden = false

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        /*
        topBackground.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.3)
        */
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dLog("view did load")

        self.title = "食譜列表"

        RecipeManager.sharedInstance.updateCachedRecipesOverviews()
        RecipeManager.sharedInstance.loadRecipes() { recipes in
            self.recipes = recipes

            print("[ RecipesViewController ] : self.recipes count : \(self.recipes.count)")

            self.tableRecipes.reloadData()
        }
        
//        RecipeManager.sharedInstance.fetchMoreRecipes()
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

// MARK: - UITableViewDataSource
extension RecipesViewController : UITableViewDataSource {

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

        cell.imgFood.image = nil
        cell.imgFood.tag = imageId

        RecipeManager.sharedInstance.loadFoodImage(imageId, imageName: imageName) { image, imageId, fadeIn in
            if (cell.imgFood.tag == imageId) {
                cell.imgFood.image = image
                cell.imgFood.alpha = 1
                
                if fadeIn {
                    cell.imgFood.alpha = 0
                    UIView.animateWithDuration(0.3) {
                        cell.imgFood.alpha = 1
                    }
                }
            }
        }
        return cell
    }
}
