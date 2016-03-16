//
//  RecipeSearchViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 3/17/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeSearchViewController: UIViewController {

  @IBOutlet weak var tagCollectionView: UICollectionView!
  var tempDatas = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()

    (1...100).forEach {
      tempDatas.append(String($0))
    }

    tagCollectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }

}

class RecipeTagCell: UICollectionViewCell {
  @IBOutlet weak var tagName: UILabel!
  @IBOutlet weak var bgView: UIView!

  var recipeTag: String! {
    didSet {
      tagName.text = recipeTag
      bgView.layer.borderColor = UIColor(hexString: "#d4cdc8").CGColor
      bgView.layer.borderWidth = 1
      bgView.layer.cornerRadius = 3
    }
  }
}

extension RecipeSearchViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tempDatas.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("recipe_tag", forIndexPath: indexPath) as! RecipeTagCell

    cell.recipeTag = tempDatas[indexPath.row]
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