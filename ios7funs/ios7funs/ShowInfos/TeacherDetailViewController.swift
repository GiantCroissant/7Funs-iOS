//
//  TeacherDetailViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/20/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class TeacherDetailViewController: UIViewController {

    @IBOutlet weak var imgTeacherProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var bgContent: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollContentHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContent: UIView!


    var teacher: InstructorDetailJsonObject!
    var bgContentHeight: CGFloat = 0
    var isDataLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = teacher.name
        ImageLoader.sharedInstance.loadDefaultImage(teacher.profileImage) { image in
            self.imgTeacherProfile.image = image
        }
        lblName.text = teacher.name

        addTeacherDatas()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentSize.height = bgContentHeight + topView.frame.height
    }

    func addTeacherDatas() {
        isDataLoaded = true
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
        var font: UIFont!
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = UIFont.systemFontOfSize(32)

        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            font = UIFont.systemFontOfSize(16)
        }

        let width = UIScreen.mainScreen().bounds.width * 0.861333

        let contentView = TeacherInfoDataView()
        let titleLabel = contentView.lblSubTitle
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.numberOfLines = 1
        titleLabel.sizeToFit()
        print("\(titleLabel.text) : \(titleLabel.frame.height)")


        var font2: UIFont!
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font2 = UIFont.boldSystemFontOfSize(32)

        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            font2 = UIFont.boldSystemFontOfSize(16)
        }

        let contentLabel = contentView.lblContent
        contentLabel.frame.size.width = width
//        contentLabel.frame.size.height = CGFloat.max
        contentLabel.text = content
        contentLabel.font = font2
        contentLabel.numberOfLines = 0
        let conSize = contentLabel.sizeThatFits(CGSize(width: width, height: CGFloat.max))

        print("\(contentLabel.text) : \(conSize.height)")

        var spacingHeight: CGFloat = 0
        contentView.spacings.forEach {
            spacingHeight += $0.constant
        }

        let titleHeight = titleLabel.frame.height
        let contentHeight = conSize.height
        let totalHeight = spacingHeight + titleHeight + contentHeight

//        contentView.bgV.sizeToFit()
//        print("contentView height = \(contentView.bgV.frame.height)")

//        let size = CGSize(width: width, height: totalHeight)

        let origin = CGPoint(x: 0, y: bgContentHeight)
        contentView.frame = CGRect(origin: origin, size: CGSize(width: width, height: totalHeight))
        

        bgContent.addSubview(contentView)
        bgContentHeight += totalHeight
        print("bgContentHeight = \(bgContentHeight)")

//        bgContent.frame.size = CGSize(width: width, height: bgContentHeight)
    }
    
}
