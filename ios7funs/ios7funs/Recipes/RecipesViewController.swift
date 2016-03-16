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
  @IBOutlet var loadingFooter: UIView!
  @IBOutlet var tableSpacing: UIView!
  @IBOutlet weak var tableRecipes: UITableView!
  @IBOutlet weak var indicatorLoadMore: UIActivityIndicatorView!

  enum StoryboardType {
    case Recipe
    case Collection
  }

  var type = StoryboardType.Recipe
  var isFetching = false
//  var recipes = [RecipeUIModel]()
  let refreshControl = UIRefreshControl()

  // Testing new way to fetch recipe
  let realm = try! Realm()
  let recipesV2 = try! Realm().objects(Recipe).sorted("id", ascending: false)
  let collections = try! Realm().objects(Recipe).filter("favorite == true").sorted("id", ascending: false)
  var notificationToken: NotificationToken?
  //

  override func viewDidLoad() {
    super.viewDidLoad()



    configureRefreshControl()

    tableRecipes.tableFooterView = loadingFooter

    if type == .Collection && LoginManager.token == nil {
      LoginManager.sharedInstance.showLoginViewController(self)
    }
  }

  func setupRealmNotificationToken() {
    switch type {
    case .Recipe:
      notificationToken = recipesV2.addNotificationBlock { results, error in
        self.tableRecipes.reloadData()
      }
    case .Collection:
      notificationToken = collections.addNotificationBlock { results, error in
        self.tableRecipes.reloadData()
      }
    }
  }

  private func configureRefreshControl() {
    let lastUpdateTime = NSUserDefaults.standardUserDefaults().stringForKey("lastRecipeOverviewUpdateTime") ?? "下拉刷新"
    refreshControl.tintColor = UIColor.orangeColor()
    refreshControl.attributedTitle = NSAttributedString(string: lastUpdateTime)
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    tableRecipes.addSubview(refreshControl)
  }

  func refresh(sender: UIRefreshControl) {
    UIUtils.showStatusBarNetworking()
    RecipeManager.sharedInstance.fetchRecipeOverview(
      onComplete: {
      },
      onError: { error in
        self.showNetworkIsBusyAlertView()
      },
      onFinished: {
        UIUtils.hideStatusBarNetworking()

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let updateString = "上次更新時間：" + dateFormatter.stringFromDate(NSDate())
        NSUserDefaults.standardUserDefaults().setObject(updateString, forKey: "lastRecipeOverviewUpdateTime")

        self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
        if (self.refreshControl.refreshing) {
          self.refreshControl.endRefreshing()
        }
      }
    )
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
//    loadRecipes()
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
        //        self.handleFetchCollectionComplete()
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

  //  func handleFetchCollectionComplete() {
  //    CollectionManager.sharedInstance.loadCollections { recipes in
  //      self.recipes = recipes
  //      self.tableRecipes.reloadData()
  //    }
  //  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.showNavigationBar()
    setupRealmNotificationToken()
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    notificationToken?.stop()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillAppear(animated)
    self.hideToastIndicator()
  }


  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    navigationItem.title = ""

    let detailVC = segue.destinationViewController as! RecipeDetailViewController
    let row = (sender?.tag)!
    detailVC.recipe = getRecipe(row)
  }

}

// MARK: - Recpie Datas
extension RecipesViewController {

//  func loadRecipes() {
//    UIUtils.showStatusBarNetworking()
//    RecipeManager.sharedInstance.loadRecipes(self.recipes) { recipes, remainCount in
//      self.recipes = recipes
//      self.tableRecipes.reloadData()
//      self.tableRecipes.tableHeaderView = recipes.count > 0 ? self.tableSpacing : nil
//      self.tableRecipes.tableFooterView = remainCount > 0 ? self.loadingFooter : self.tableSpacing
//      UIUtils.hideStatusBarNetworking()
//    }
//  }

}

// MARK: - UITableViewDataSource
extension RecipesViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch type {
    case .Recipe:
      return recipesV2.count

    case .Collection:
      return collections.count
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("idRecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell

    let recipe = getRecipe(indexPath.row)  // recipesV2[indexPath.row]


    cell.recipe = recipe
    cell.updateCell()

    let favoriteButton = cell.btnAddCollection as! RecipeFavoriteButton
    favoriteButton.tag = recipe.id
    favoriteButton.row = indexPath.row

    cell.btnFood.tag = indexPath.row

    return cell
  }

  func getRecipe(row: Int) -> Recipe {
    switch type {
    case .Recipe:
      return recipesV2[row]

    case .Collection:
      return collections[row]
    }
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

    if self.traitCollection.verticalSizeClass
      == .Regular && self.traitCollection.horizontalSizeClass == .Regular {

        return 458
    }

    return 258
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

        let recipe = self.getRecipe(index)

        self.realm.beginWrite()
        recipe.favorite = isFavorite
        try! self.realm.commitWrite()

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

//// MARK: - UITableViewDelegate
//extension RecipesViewController: UITableViewDelegate {
//
//  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//    if type == .Recipe {
//      let distFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
//      if (distFromBottom <= scrollView.frame.height) {
//        loadRecipes()
//      }
//    }
//  }
//  
//}
