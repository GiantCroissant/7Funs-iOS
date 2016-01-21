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

    @IBOutlet var photoBG: [UIView]!
    
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

        // Do any additional setup after loading the view.
        
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
            .subscribeNext({ x in
                // MARK: Should have all the data from info json
                x?.instructors.forEach({ ijo in
                    // Large image
                    // ijo.image
                    // Smaller image
                    // ijo.profileImage
                })
                print(x)
            })


        for photo in photoBG {
            photo.layer.cornerRadius = 5
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
