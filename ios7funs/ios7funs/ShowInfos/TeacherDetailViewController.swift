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

    @IBOutlet weak var bgContent: UIView!
    @IBOutlet var contentHSpacing: [NSLayoutConstraint]!
    @IBOutlet weak var contentVBottomSpacing: NSLayoutConstraint!
    
    var teacher: InstructorDetailJsonObject!
    var bgContentHeight: CGFloat = 0

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

        let contentHeight = bgContentHeight + topView.frame.height + contentVBottomSpacing.constant
        scrollView.contentSize.height = contentHeight
        print("viewDidLayoutSubviews scroll view height = \(scrollView.contentSize.height)")
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
        var hSpacing: CGFloat = 0
        contentHSpacing.forEach {
            hSpacing += $0.constant
        }
        let contentWidth = UIScreen.mainScreen().bounds.width - hSpacing

        var font: UIFont!
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = UIFont.systemFontOfSize(32)

        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            font = UIFont.systemFontOfSize(16)
        }

        let contentView = TeacherInfoDataView()

        let titleLabel = contentView.lblSubTitle
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.numberOfLines = 1
        titleLabel.sizeToFit()

        var font2: UIFont!
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font2 = UIFont.boldSystemFontOfSize(32)

        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            font2 = UIFont.boldSystemFontOfSize(16)
        }

        var horizontalSpacing: CGFloat = 0
        contentView.horizontalSpacing.forEach {
            horizontalSpacing += $0.constant
        }

        let contentLabel = contentView.lblContent
        contentLabel.frame.size.width = contentWidth - horizontalSpacing
        contentLabel.text = content
        contentLabel.font = font2
        titleLabel.numberOfLines = 0
        contentLabel.sizeToFit()

        var spacingHeight: CGFloat = 0
        contentView.spacings.forEach {
            spacingHeight += $0.constant
        }

        let titleHeight = titleLabel.frame.height
        let contentHeight = contentLabel.frame.height
        let totalHeight = spacingHeight + titleHeight + contentHeight

        let origin = CGPoint(x: 0, y: bgContentHeight)
        let size = CGSize(width: contentWidth, height: totalHeight)
        contentView.frame = CGRect(origin: origin, size: size)

        bgContent.addSubview(contentView)
        bgContentHeight += totalHeight
    }
    
}
