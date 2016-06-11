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
  @IBOutlet var loadMoreView: UIView!

  let initialPageNumber = 1
  var questions = [QuestionUIModel]()
  var targetPage = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    targetPage = initialPageNumber
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.title = "美食問與答"
    self.showToastIndicator()
    QandAManager.sharedInstance.fetchQuestions(
      targetPage,
      onComplete: { questions, isLast -> Void in
        self.tableQuestions.tableFooterView = isLast ? nil : self.loadMoreView
        self.questions = questions
        self.tableQuestions.reloadData()
      },
      onError: { error in
        self.showNetworkIsBusyAlertView()
      },
      onFinished: {
        self.hideToastIndicator()
      }
    )
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    showNavigationBar()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    navigationItem.title = ""

    let vc = segue.destinationViewController
    if vc.title == "Reply Question" {
      let detailVC = vc as! QandADetailViewController
      let row = (sender?.tag)!
      detailVC.question = questions[row]
    }
  }
}


// MARK: - UITableViewDataSource
extension QandAViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return questions.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("id_cell_question", forIndexPath: indexPath) as! QuestionTableViewCell

    let question = questions[indexPath.row]
    cell.question = question
    cell.tag = indexPath.row

    return cell
  }

}
