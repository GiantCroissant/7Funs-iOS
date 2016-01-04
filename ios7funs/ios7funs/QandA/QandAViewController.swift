//
//  QandAViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class QandAViewController: UIViewController {

    @IBOutlet weak var tableQuestions: UITableView!
    var questions = [QuestionUIModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        QandAManager.sharedInstance.fetchQuestions(
            onComplete: { questions -> Void in
                dLog("questions.count = \(questions.count)")

                self.questions = questions
                self.tableQuestions.reloadData()

            },
            onError: { error in

            },
            onFinished: {

            }
        )
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "美食問與答"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showNavigationBar()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""
    }
}


// MARK: - UITableViewDataSource
extension QandAViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("id_cell_question", forIndexPath: indexPath) as! QuestionTableViewCell

        cell.question.text = questions[indexPath.row].description
        
        return cell
    }

}
