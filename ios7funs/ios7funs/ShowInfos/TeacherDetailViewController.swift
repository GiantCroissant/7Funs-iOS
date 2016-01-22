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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = teacher.name

        ImageLoader.sharedInstance.loadDefaultImage(teacher.profileImage) { image in
            self.imgTeacherProfile.image = image
        }

        lblName.text = teacher.name


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if teacher.experience != "" {
            let contentView = TeacherInfoDataView()
            contentView.lblSubTitle.text = "廚藝經驗"
            contentView.lblContent.text = teacher.experience
            contentView.lblSubTitle.sizeToFit()
            contentView.lblContent.sizeToFit()

            var spacingHeight: CGFloat = 0
            contentView.spacings.forEach {
                spacingHeight += $0.constant
            }

            let titleHeight = contentView.lblSubTitle.frame.height
            let contentHeight = contentView.lblContent.frame.height
            let totalHeight = spacingHeight + titleHeight + contentHeight

            let width = bgContent.frame.width
            let size = CGSize(width: width, height: totalHeight)
            contentView.frame = CGRect(origin: CGPoint.zero, size: size)
            bgContent.addSubview(contentView)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)



    }

}
