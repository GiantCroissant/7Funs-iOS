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
    @IBOutlet weak var indicatorLoadMore: UIActivityIndicatorView!

    enum StoryboardType {
        case Recipe
        case Collection
    }

    var type = StoryboardType.Recipe
    var isFetching = false
    var recipes = [RecipeUIModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if type == .Collection {
            if (LoginManager.token == nil)  {
                LoginManager.sharedInstance.showLoginViewController(self)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if type == .Recipe {
            onRecipeVCWillAppear()
        }

        if type == .Collection {
            onCollectionVCWillAppear()
        }
    }

    func onRecipeVCWillAppear() {
        self.title = "食譜列表"
        indicatorLoadMore.startAnimating()
        loadRecipes(onEmpty: {
            self.fetchMoreRecipes()
        })
    }

    func onCollectionVCWillAppear() {
        self.title = "我的收藏"
        UIUtils.showStatusBarNetworking()
        guard let token = LoginManager.token else {
            return
        }

        indicatorLoadMore.startAnimating()
        CollectionManager.sharedInstance.fetchCollections(token,
            onComplete: {
                self.handleFetchCollectionComplete()
            },
            onError: { err in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                UIUtils.hideStatusBarNetworking()
                self.indicatorLoadMore.stopAnimating()
            }
        )
    }

    func handleFetchCollectionComplete() {
        CollectionManager.sharedInstance.loadCollections { recipes in
            self.recipes = recipes
            self.tableRecipes.reloadData()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideToastIndicator()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
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
                self.showNetworkIsBusyAlertView()
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idRecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell

        let recipe = recipes[indexPath.row]
        cell.recipe = recipe
        cell.updateCell()

        let favoriteButton = cell.btnAddCollection as! RecipeFavoriteButton
        favoriteButton.tag = recipe.id
        favoriteButton.row = indexPath.row

        cell.btnFood.tag = indexPath.row

        return cell
    }
}

class RecipeFavoriteButton: UIButton {
    var row: Int = 0
}

// MARK: - Switch favorite state
extension RecipesViewController {

    @IBAction func onAddToCollectionClick(sender: RecipeFavoriteButton) {
        guard let token = LoginManager.token else {
            LoginManager.sharedInstance.showLoginViewController(self)
            return
        }

        switchFavorite(sender, token: token)
    }

    func switchFavorite(favoriteButton: RecipeFavoriteButton, token: String) {
        let recipeId = favoriteButton.tag
        let index = favoriteButton.row

        UIUtils.showStatusBarNetworking()
        RecipeManager.sharedInstance.switchFavorite(recipeId, token: token,
            onComplete: { isFavorite in
                let recipe = self.recipes[index]
                recipe.favorite = isFavorite
                self.tableRecipes.reloadData()
                self.showSwitchFavoriteToast(recipe)
            },
            onError: { _ in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                UIUtils.hideStatusBarNetworking()
            }
        )
    }

}

// MARK: - UITableViewDelegate
extension RecipesViewController: UITableViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if type == .Recipe {
            let distFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
            if (distFromBottom <= scrollView.frame.height) {
                fetchMoreRecipes()
            }
        }
    }
    
}
