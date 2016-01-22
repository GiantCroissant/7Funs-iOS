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

    let disposeBag = DisposeBag()
    var teachers = [InstructorDetailJsonObject]()

    
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
                instructorJsonObject?.instructors.forEach {
                    self.teachers.append($0)
                    self.collectionTeachers.reloadData()
                }
            }
            .addDisposableTo(disposeBag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class TeacherCollectionCell: UICollectionViewCell {

    @IBOutlet weak var bgContent: UIView!
    @IBOutlet weak var imgTeacherPhoto: UIImageView!
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
        cell.imgTeacherPhoto.image = UIImage(named: teacher.image)
        cell.lblName.text = teacher.name
        cell.lblDescription.text = teacher.shortDescription
        cell.lblDescription.numberOfLines = teacher.shortDescription.characters.split("\n").count
        return cell
    }

}


extension ShowTeacherViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let width = collectionView.bounds.width / 2
        let height = collectionView.bounds.height / 2

        return CGSize(width: width, height: height)
    }

}
