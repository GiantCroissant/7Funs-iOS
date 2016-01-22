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
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if isDataLoaded {
//            return
//        }
//        addTeacherDatas()
//    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        addTeacherDatas()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        addTeacherDatas()
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
        let width = UIScreen.mainScreen().bounds.width * 0.861333

        let contentView = TeacherInfoDataView()
        contentView.lblSubTitle.frame.size.width = width
        contentView.lblSubTitle.text = title
        contentView.lblSubTitle.numberOfLines = 1
        contentView.lblSubTitle.sizeToFit()

        contentView.lblContent.frame.size.width = width
        contentView.lblContent.text = content
        contentView.lblContent.numberOfLines = 0
        contentView.lblContent.sizeToFit()

        var spacingHeight: CGFloat = 0
        contentView.spacings.forEach {
            spacingHeight += $0.constant
        }

        let titleHeight = contentView.lblSubTitle.frame.height
        let contentHeight = contentView.lblContent.frame.height
        let totalHeight = spacingHeight + titleHeight + contentHeight

        let size = CGSize(width: width, height: totalHeight)
        let origin = CGPoint(x: 0, y: bgContentHeight)
        contentView.frame = CGRect(origin: origin, size: size)

        bgContentHeight += totalHeight
        bgContent.addSubview(contentView)
        bgContent.frame.size = CGSize(width: width, height: bgContentHeight)
    }

}
