//
//  TeacherDetailViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/20/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class TeacherDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imgTeacherProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoContainerBottomSpacing: NSLayoutConstraint!
    @IBOutlet var infoContainerHorizontalSpacings: [NSLayoutConstraint]!

    var teacher: InstructorDetailJsonObject!

    let fontSizeIPad: CGFloat = 32
    let fontSizeIPhone: CGFloat = 16
    var fontSubTitle: UIFont!
    var fontContent: UIFont!

    var containerHeight: CGFloat = 0
    var containerWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = teacher.name
        ImageLoader.sharedInstance.loadDefaultImage(teacher.profileImage) { image in
            self.imgTeacherProfile.image = image
        }
        lblName.text = teacher.name

        let horizontalSpacing = infoContainerHorizontalSpacings.reduce(0) { $0 + $1.constant }
        containerWidth = UIScreen.mainScreen().bounds.width - horizontalSpacing

        setupFonts()
        addTeacherDatas()
    }

    func setupFonts() {
        let idiom = UIDevice.currentDevice().userInterfaceIdiom
        var fontSize: CGFloat = 0
        if idiom == .Pad {
            fontSize = fontSizeIPad

        } else if idiom == .Phone {
            fontSize = fontSizeIPhone
        }
        fontSubTitle = UIFont.systemFontOfSize(fontSize)
        fontContent = UIFont.boldSystemFontOfSize(fontSize)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let contentHeight = containerHeight
            + topView.frame.height
            + infoContainerBottomSpacing.constant

        scrollView.contentSize.height = contentHeight
    }

    func addTeacherDatas() {
        if teacher.experience != "" {
            addTeacherData("廚藝經驗", content: teacher.experience)
        }
        if teacher.specialty != "" {
            addTeacherData("擅長料理", content: teacher.specialty)
        }
        if teacher.currentTitle != "" {
            addTeacherData("現任", content: teacher.currentTitle)
        }
        if teacher.books != "" {
            addTeacherData("著作", content: teacher.books)
        }
        if teacher.awards != "" {
            addTeacherData("曾獲", content: teacher.awards)
        }
    }

    func addTeacherData(title: String, content: String) {
        let infoView = TeacherInfoDataView()
        infoView.setupSubTitle(title, font: fontSubTitle)
        infoView.setupContent(content, font: fontContent, containerWidth: containerWidth)

        let infoViewHeight = infoView.getHeight()

        infoView.frame = CGRectMake(0, containerHeight, containerWidth, infoViewHeight)
        infoContainer.addSubview(infoView)
        containerHeight += infoViewHeight
    }
    
}
