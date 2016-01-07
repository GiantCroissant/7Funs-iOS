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
        navigationItem.title = "" // TODO: this line should be move to destination VC ?

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

    // FIXME: this func here just because I need to presnet login VC
    // maybe there's better way to refactor this func to tableCell class
    @IBAction func onAddToCollectionClick(sender: UIButton) {
        if let token = LoginManager.token {
            let recipeId = sender.tag
            RecipeManager.sharedInstance.addOrRemoveFavorite(recipeId, token: token)

        } else {
            LoginManager.sharedInstance.showLoginViewController(self)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idRecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell


        let recipe = recipes[indexPath.row]
        cell.recipe = recipe
        cell.btnAddCollection.tag = recipe.id
        cell.btnFood.tag = indexPath.row

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
