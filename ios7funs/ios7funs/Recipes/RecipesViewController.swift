//
//  RecipesViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var topBackground: UIView!

    var data = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
        "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
        "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
        "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
        "Pear", "Pineapple", "Raspberry", "Strawberry"]


    @IBOutlet weak var tableRecipes: UITableView!

    var recipes = [RecipeUI]()

    func scrollViewDidScroll(scrollView: UIScrollView) {

        print("y = \(scrollView.contentOffset.y)")
        let y = scrollView.contentOffset.y
        if (y > 0) {
            topBackground.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(1 - ((100 - y) / 100))
        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Show navigation bar.
        self.navigationController?.navigationBarHidden = false

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        topBackground.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.3)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "食譜列表"

        RecipeManager.sharedInstance.updateCachedRecipesOverviews()
        RecipeManager.sharedInstance.loadRecipes { (recipes) -> () in
            print("[ RecipeManager ] : load recipes from data completed")

            self.recipes = recipes
            self.tableRecipes.reloadData()
        }

        tableRecipes.tableHeaderView = UIView(frame: CGRectMake(0, 0, 320,64))
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idRecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell

        if (indexPath.row >= recipes.count) {
            return cell
        }

        let recipe = recipes[indexPath.row]
        let imageId = recipe.imageId
        let imageName = recipe.imageName

        RecipeManager.sharedInstance.loadFoodImageById(imageId, imageName: imageName) { (image) -> () in

            cell.imgFood.image = image

        }
        return cell
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
