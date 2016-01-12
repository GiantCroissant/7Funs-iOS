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
            self.title = "食譜列表"
            indicatorLoadMore.hidden = false
            indicatorLoadMore.startAnimating()

            loadRecipes(onEmpty: {
                self.fetchMoreRecipes()
            })
        }

        if type == .Collection {
            self.title = "我的收藏"
            indicatorLoadMore.hidesWhenStopped = true
            indicatorLoadMore.stopAnimating()

            self.showToastIndicator()
            if let token = LoginManager.token {
                CollectionManager.sharedInstance.fetchCollections(token,
                    onComplete: {
                        self.handleFetchCollectionComplete()
                    },
                    onError: { err in
                        self.showNetworkIsBusyAlertView()
                    },
                    onFinished: {
                        self.hideToastIndicator()
                    }
                )
            }
        }

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
        self.recipes.removeAll()
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

    // FIXME: this func here just because I need to presnet login VC
    // maybe there's better way to refactor this func to tableCell class
    @IBAction func onAddToCollectionClick(sender: RecipeFavoriteButton) {
        if let token = LoginManager.token {
            let recipeId = sender.tag

            UIUtils.showStatusBarNetworking()
            RecipeManager.sharedInstance.addOrRemoveFavorite(recipeId, token: token,
                onComplete: { favorite in
                    let uiRecipe = self.recipes[sender.row]
                    uiRecipe.favorite = favorite
                    self.tableRecipes.reloadData()

                    let recipeName = uiRecipe.title
                    let msg = favorite ? "\(recipeName) : 加入收藏" : "\(recipeName) : 取消收藏"
                    self.view.makeToast(msg, duration: 1, position: .Top)
                    UIUtils.hideStatusBarNetworking()
                }
            )

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

// MARK: - UITableViewDelegate
extension RecipesViewController: UITableViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let distFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
        if (distFromBottom <= scrollView.frame.height) {
            if type == .Recipe {
                fetchMoreRecipes()
            }
        }
    }
    
}
