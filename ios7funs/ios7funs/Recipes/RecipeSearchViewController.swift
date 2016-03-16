//
//  RecipeSearchViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 3/17/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeSearchViewController: UIViewController {

  @IBOutlet weak var tagCollectionView: UICollectionView!
  let recipeTags = try! Realm().objects(RecipeTag).sorted("id", ascending: true)
  let searchController = UISearchController(searchResultsController: nil)

  @IBAction func onSearchButtonClick(sender: UIBarButtonItem) {
    presentViewController(searchController, animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "食譜搜尋"
    tagCollectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

    configureSearchController()
    configureSearchBar()
    configureSearchBarCancelButton()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    print("sender = \(sender)")

    if segue.identifier == "tag_search" && sender is UISearchBar {

      print("UISearchBar")

      let detailVC = segue.destinationViewController as! RecipesViewController


      let bar = sender as! UISearchBar
//      let row = (sender?.tag)!
//      let recipeIds = recipeTags[row].recipeIds

      print("bar.text = \(bar.text)")
      detailVC.title = bar.text


      detailVC.type = RecipesViewController.StoryboardType.Search
      detailVC.searchResults = try! Realm().objects(Recipe)
        .filter("title CONTAINS %@" +
          " OR chefName CONTAINS %@" +
          " OR ingredient CONTAINS %@" +
          " OR seasoning CONTAINS %@"
          , bar.text!, bar.text!, bar.text!, bar.text!)
        .sorted("id", ascending: false)

    }

    else if segue.identifier == "tag_search" {
      let detailVC = segue.destinationViewController as! RecipesViewController

      let row = (sender?.tag)!
      let recipeIds = recipeTags[row].recipeIds
      detailVC.title = recipeTags[row].name
      detailVC.type = RecipesViewController.StoryboardType.Search
      detailVC.searchResults = try! Realm().objects(Recipe)
        .filter("id IN %@", recipeIds)
        .sorted("id", ascending: false)
      
    }
  }

}

class RecipeTagCell: UICollectionViewCell {
  @IBOutlet weak var tagName: UILabel!
  @IBOutlet weak var bgView: UIView!

  var recipeTag: RecipeTag! {
    didSet {
      tagName.text = recipeTag.name
      bgView.layer.borderColor = UIColor(hexString: "#d4cdc8").CGColor
      bgView.layer.borderWidth = 1
      bgView.layer.cornerRadius = 3
    }
  }
}

extension RecipeSearchViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return recipeTags.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("recipe_tag", forIndexPath: indexPath) as! RecipeTagCell
    cell.tag = indexPath.row
    cell.recipeTag = recipeTags[indexPath.row]
    return cell
  }

}

extension RecipeSearchViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

    let width = (collectionView.bounds.width - 10) / 2
    let height: CGFloat = 60
    return CGSize(width: width, height: height)
  }

}


extension RecipeSearchViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    dismissViewControllerAnimated(true, completion: nil)
    performSegueWithIdentifier("tag_search", sender: searchBar)
  }

  //    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
  //        dismissViewControllerAnimated(true, completion: nil)
  //    }

  func configureSearchController() {
    //    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = true
    searchController.hidesNavigationBarDuringPresentation = false
  }

  func configureSearchBar() {
    let searchBar = searchController.searchBar
    searchBar.placeholder = "搜尋食譜..."
    searchBar.barTintColor = UIColor.orangeColor()
    searchBar.tintColor = UIColor.darkGrayColor()
    searchBar.delegate = self
    searchBar.sizeToFit()
  }

  func configureSearchBarCancelButton() {
    if #available(iOS 9.0, *) {
      let item = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])
      item.tintColor = UIColor.whiteColor()
      item.title = " 取消 "

    } else {
      // Fallback on earlier versions
    }
  }
  
}


