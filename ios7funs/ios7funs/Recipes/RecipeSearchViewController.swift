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

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "食譜搜尋"
    tagCollectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "tag_search" {
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