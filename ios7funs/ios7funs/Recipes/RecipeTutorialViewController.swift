//
//  RecipeTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTutorialViewController: UIViewController {

    let headerImageHeight: CGFloat = 211
    var blurView: UIVisualEffectView!
    var recipe: RecipeUIModel!

    @IBOutlet weak var btnAddFavorite: UIButton!
    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var labelFoodTitle: UILabel!
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var lblIngredients: UILabel!
    @IBOutlet weak var lblSeasonings: UILabel!
    @IBOutlet weak var lblMethods: UILabel!
    @IBOutlet weak var bgTutorial: CardView!
    @IBOutlet weak var bgContent: UIView!
    @IBOutlet weak var bgBottom: UIView!
    @IBOutlet weak var layoutContentHeight: NSLayoutConstraint!
    @IBOutlet var layoutDynamicHeights: [NSLayoutConstraint]!

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBAction func onAddFavoriteClick(sender: UIButton) {
        if let token = LoginManager.token {
            requestSwitchFavoriteState(token)

        } else {
            LoginManager.sharedInstance.showLoginViewController(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recipe.printDebugString()

        recipe.loadFoodImage { image in
            self.imgFood.image = image
        }

        labelFoodTitle.text = recipe.title
        foodTitle.text = recipe.title

        configureFoodImageBlurEffect()
        configureFavoriteButton(recipe.favorite)
        configureInformation()
        configureTutorial()

//        let width = bgContent.frame.width
//        bgContent.frame.size = CGSize(width: width, height: 10000)

//        layoutContentHeight.constant = 1000

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bounds = self.bgBottom.bounds
        let size = self.bgBottom.sizeThatFits(CGSize(width: bounds.width, height: 10000))
        print("size = \(size)")

        var newHeight: CGFloat = 0.0
        for height in layoutDynamicHeights {
            newHeight += height.constant
        }


        layoutContentHeight.constant = newHeight + size.height

        contentScrollView.contentSize.height = layoutContentHeight.constant
    }

    func configureTutorial() {
        let ingredient = recipe.ingredient
        let seasoning = recipe.seasoning
        lblIngredients.text = reformatIngredientString(ingredient)
        lblSeasonings.text = reformatSeasoningString(seasoning)
        lblMethods.text = recipe.method
    }

    func reformatIngredientString(ingredient: String) -> String {
        let ingredients = ingredient.componentsSeparatedByString("、")
        var ingredientText: String = ""
        for ingre in ingredients {
            ingredientText.appendContentsOf(ingre)
            ingredientText.appendContentsOf("\n")
        }
        let range = ingredientText.endIndex.advancedBy(-2)..<ingredientText.endIndex
        ingredientText.removeRange(range)
        return ingredientText
    }

    func reformatSeasoningString(seasoning: String) -> String {
        let seasonings = seasoning.componentsSeparatedByString("、")
        var seasoningText: String = ""
        for sea in seasonings {
            seasoningText.appendContentsOf(sea)
            seasoningText.appendContentsOf("\n")
        }
        if seasoningText.characters.count > 2 {
            let range = seasoningText.endIndex.advancedBy(-2)..<seasoningText.endIndex
            seasoningText.removeRange(range)
        }
        return seasoningText
    }

    func configureInformation() {
        let collectedCount = recipe.collectedCount
        let hits = recipe.hits
        lblInformation.text = "\(collectedCount)人收藏，\(hits)人看過"
    }

    func configureFoodImageBlurEffect() {
        let darkBlur = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imgFood.bounds
        blurView.alpha = 0
        imgFood.addSubview(blurView)
    }

    private func configureFavoriteButton(favorite: Bool) {
        let imageName = favorite ? "icon_love_m_pink" : "icon_love_m"
        let image = UIImage(named: imageName)
        btnAddFavorite.setImage(image, forState: .Normal)
    }

    func requestSwitchFavoriteState(token: String) {
        let recipeId = recipe.id

        UIUtils.showStatusBarNetworking()
        RecipeManager.sharedInstance.addOrRemoveFavorite(recipeId, token: token,
            onComplete: { favorite in
                self.handleFavoriteUpdateSuccess(favorite)
            },
            onError: { _ in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                UIUtils.hideStatusBarNetworking()
            }
        )
    }

    func handleFavoriteUpdateSuccess(favorite: Bool) {
        let recipeName = self.recipe.title
        let msg = favorite ? "\(recipeName) : 加入收藏" : "\(recipeName) : 取消收藏"
        self.view.makeToast(msg, duration: 1, position: .Top)

        // update cache recipe UI model
        self.recipe.favorite = favorite

        // update Add Favorite Button UI
        self.configureFavoriteButton(favorite)
    }

}


// MARK: - Dynamic parallax UI effect
extension RecipeTutorialViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        updateFoodLabel(offsetY)
        updateHeaderImageView(offsetY)
        updateBlurView(offsetY)
    }

    func updateFoodLabel(offsetY: CGFloat) {
        let x = labelFoodTitle.frame.origin.x
        var y = -offsetY + headerImageHeight - 20
        if (y < 12) {
            y = 12
        }

        let h = labelFoodTitle.frame.size.height
        let w = labelFoodTitle.frame.size.width
        labelFoodTitle.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func updateHeaderImageView(offsetY: CGFloat) {
        let w = imgFood.frame.size.width
        var h = headerImageHeight - offsetY
        if (h <= 64) {
            h = 64
        }

        imgFood.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }

    func updateBlurView(offsetY: CGFloat) {
        blurView.alpha = 1 - ((headerImageHeight - offsetY) / headerImageHeight)
    }
    
}