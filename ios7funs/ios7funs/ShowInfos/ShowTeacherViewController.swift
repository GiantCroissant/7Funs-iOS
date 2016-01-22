//
//  ShowTeacherViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

import Argo
import Curry
import RxSwift

class ShowTeacherViewController: UIViewController {

    @IBOutlet weak var collectionTeachers: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    let disposeBag = DisposeBag()
    var teachers = [InstructorDetailJsonObject]()
    var showInfosVC: ShowInfosViewController!

    let infoDataSource: Observable<String> = Observable.create { (observer) in
        let fileName = "Info"
        let fileType = "json"

        let defaultContent = "{\"instructors\": []}"

        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)
        let content: String = path.map { x in
            do {
                let data = try String(contentsOfFile: x)
                return data
            } catch {
                return defaultContent
            }
            } ?? defaultContent

        observer.on(.Next(content))
        observer.on(.Completed)
        return AnonymousDisposable {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.showToastIndicator()
        pageControl.hidden = true
        loadTeachers()
    }

    func loadTeachers() {
        infoDataSource
            .observeOn(BackgroundScheduler.instance())
            .map({ (s: String) -> InstructorJsonObject? in
                let data = s.dataUsingEncoding(NSUTF8StringEncoding)

                if let d = data {
                    do {
                        let jsonObject = try NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [String : AnyObject]
                        let decoded = InstructorJsonObject.self.decode(JSON.parse(jsonObject))
                        switch decoded {
                        case .Success(let result):
                            return result

                        case .Failure:
                            return nil
                        }
                    } catch {
                        return nil
                    }
                }

                return nil
            })
            .observeOn(MainScheduler.instance)
            .subscribeNext { instructorJsonObject in
                self.configureLayout(instructorJsonObject)
            }
            .addDisposableTo(disposeBag)
    }

    func configureLayout(instructorJsonObject: InstructorJsonObject?) {
        instructorJsonObject?.instructors.forEach {
            teachers.append($0)
        }
        addEmptyTeacherCells()

        // configure page control
        let pageCount = Int(ceilf(Float(teachers.count) / 4))
        pageControl.numberOfPages = pageCount
        pageControl.hidden = false

        // display collection view
        collectionTeachers.reloadData()

        self.hideToastIndicator()
    }

    func addEmptyTeacherCells() {
        var emptyCellCount: Int = 4 - (teachers.count % 4)
        let emptyTeacher = InstructorDetailJsonObject(
            name: "",
            image: "teacher_Male",
            shortDescription: "更多名師主廚\n新增中...",
            profileImage: "",
            experience: "",
            specialty: "",
            currentTitle: "",
            books: "",
            awards: ""
        )

        while emptyCellCount > 0 {
            teachers.append(emptyTeacher)
            emptyCellCount--
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        showInfosVC.title = ""

        let detailVC = segue.destinationViewController as! TeacherDetailViewController
        let row = (sender?.tag)!
        detailVC.teacher = teachers[row]
    }

}

class TeacherCollectionCell: UICollectionViewCell {

    @IBOutlet weak var bgContent: UIView!
    @IBOutlet weak var btnTeacherDetail: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

}

extension ShowTeacherViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teachers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let teacher = teachers[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("id_collection_cell_teacher", forIndexPath: indexPath) as! TeacherCollectionCell

        cell.bgContent.layer.cornerRadius = 5
        cell.btnTeacherDetail.tag = indexPath.row

        ImageLoader.sharedInstance.loadDefaultImage(teacher.image) { image in

            let scaledImage = self.scaleImage(image!, cell: cell)
            cell.btnTeacherDetail.imageView?.contentMode = .Top
            cell.btnTeacherDetail.setImage(scaledImage, forState: .Normal)
        }

        cell.lblName.text = teacher.name
        cell.lblDescription.text = teacher.shortDescription
        cell.lblDescription.numberOfLines = teacher.shortDescription.characters.split("\n").count
        cell.userInteractionEnabled = teacher.name.isEmpty ? false : true
        return cell
    }

    func scaleImage(image: UIImage, cell: TeacherCollectionCell) -> UIImage {
        let imageRatio = image.size.height / image.size.width
        let cellRatio = cell.frame.height / cell.frame.width

        var scaledImage: UIImage!
        if imageRatio > cellRatio {
            let width = cell.frame.size.width
            scaledImage = UIImage.scaleImageToWidth(image, newWidth: width)

        } else {
            let height = cell.frame.size.height
            scaledImage = UIImage.scaleImageToHeight(image, newHeight: height)
        }
        return scaledImage
    }

}


extension ShowTeacherViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2
        let height = collectionView.bounds.height / 2
        return CGSize(width: width, height: height)
    }

}


extension ShowTeacherViewController: UICollectionViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
        pageControl.currentPage = page
    }
    
}

