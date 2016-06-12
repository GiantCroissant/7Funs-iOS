//
//  RecipeTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTutorialViewController: UIViewController {

    @IBOutlet var containerHorizontalSpacings: [NSLayoutConstraint]!
    @IBOutlet var containerVertiaclSpacings: [NSLayoutConstraint]!
    @IBOutlet weak var btnAddFavorite: RecipeFavoriteButton!
    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var labelFoodTitle: UILabel!
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var lblIngredients: UILabel!
    @IBOutlet weak var lblSeasonings: UILabel!
    @IBOutlet weak var bgTutorial: CardView!
    @IBOutlet weak var bgContent: UIView!
    @IBOutlet weak var bgBottom: UIView!
    @IBOutlet weak var bottomToTopHeight: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var leftContainerOffset: NSLayoutConstraint!

    let screenWidth = UIScreen.mainScreen().bounds.width
    var containerHeight: CGFloat = 0
    var containerWidth: CGFloat = 0
    var fontNumber: UIFont!
    var fontMethod: UIFont!
    let headerImageHeight: CGFloat = 211
    var blurView: UIVisualEffectView!
//    var recipe: RecipeUIModel!
  var recipe: Recipe!

    @IBAction func onAddFavoriteClick(sender: UIButton) {
        if let token = LoginManager.token {
            requestSwitchFavoriteState(token)

        } else {
            LoginManager.sharedInstance.showLoginViewController(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()



        recipe.loadFoodImage { image in
            self.imgFood.image = image
        }

        labelFoodTitle.text = recipe.title
        foodTitle.text = recipe.title
        setupFonts()
        setupContainerWidth()
        configureFoodImageBlurEffect()
        configureFavoriteButton(recipe.favorite)
        configureInformation()
        configureTutorial()

        showToastIndicator()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        containerHeight = bgTutorial.frame.height

        addRecipeMethods()
        configureScrollViewContentHeight()
        hideToastIndicator()
    }

    func configureScrollViewContentHeight() {
        let newHeight = bottomToTopHeight.constant
            + containerHeight
            + containerVertiaclSpacings.reduce(0) { $0 + $1.constant }
        contentScrollView.contentSize.height = newHeight
    }

    func configureTutorial() {
        let ingredient = recipe.ingredient
        let seasoning = recipe.seasoning
        lblIngredients.attributedText = reformatTutorialString(ingredient).addLineSpacing(4)
        lblSeasonings.attributedText = reformatTutorialString(seasoning).addLineSpacing(4)
    }

    func addRecipeMethods() {
        for index in 0..<recipe.method.count {
            let stepNumber = String(index + 1)
            let content = recipe.method[index]

            let methodView = RecipeMethod()
            methodView.setupNumber(stepNumber, font: fontNumber)
            methodView.setupMethod(content, font: fontMethod, containerWidth: containerWidth)

            let methodViewHeight = methodView.getHeight()

            // FIXME: temporary fix, but seems too hacky
            let bg = UIView(frame: CGRect(x: -leftContainerOffset.constant, y: containerHeight, width: screenWidth, height: methodViewHeight))
            bg.backgroundColor = UIColor(hexString: "#f6f4ef")
            methodView.frame = CGRectMake(0, containerHeight, containerWidth, methodViewHeight)

            bgTutorial.addSubview(bg)
            bgTutorial.addSubview(methodView)
            containerHeight += methodViewHeight
        }
    }

    func reformatTutorialString(ingredient: String) -> String {
        let ingredients = ingredient.componentsSeparatedByString("、")
        var ingredientText: String = ""

        for i in 0..<ingredients.count {
            let ingre = ingredients[i]
            ingredientText.appendContentsOf(ingre)

            if i < ingredients.count - 1 {
                ingredientText.appendContentsOf("\n")
            }
        }

        if ingredientText.isEmpty {
            ingredientText = "無"
        }
        return ingredientText
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
    if (btnAddFavorite.isUploading) {
      return
    }
    btnAddFavorite.isUploading = true
    let uploadingImage = UIImage(named: "icon_love_m_pink_uploading")
    btnAddFavorite.setImage(uploadingImage, forState: .Normal)

    let recipeId = recipe.id
    UIUtils.showStatusBarNetworking()
    RecipeManager.sharedInstance.switchFavorite(
      recipeId,
      token: token,
      onComplete: { favorite in
        self.handleFavoriteUpdateSuccess(favorite)
      },
      onError: { _ in
        self.showNetworkIsBusyAlertView()
      },
      onFinished: {
        UIUtils.hideStatusBarNetworking()
        self.btnAddFavorite.isUploading = false
      }
    )
  }

    func handleFavoriteUpdateSuccess(favorite: Bool) {
        configureFavoriteButton(favorite)
        showSwitchFavoriteToast(favorite, recipeName: recipe.title)
    }

    func setupContainerWidth() {
        let horizontalSpacing = containerHorizontalSpacings.reduce(0) { $0 + $1.constant }
        containerWidth = screenWidth - horizontalSpacing
    }

    func setupFonts() {
        let idiom = UIDevice.currentDevice().userInterfaceIdiom
        if idiom == .Pad {
            fontNumber = UIFont.boldSystemFontOfSize(46)
            fontMethod = UIFont.systemFontOfSize(32, weight: UIFontWeightLight)

        } else if idiom == .Phone {
            fontNumber = UIFont.boldSystemFontOfSize(23)
            fontMethod = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        }
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
        let w = blurView.frame.size.width
        var h = headerImageHeight - offsetY
        if (h <= 64) {
            h = 64
        }

        blurView.alpha = 1 - ((headerImageHeight - offsetY) / headerImageHeight)
        blurView.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }
    
}