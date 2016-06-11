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

  let refreshControl = UIRefreshControl()
  let lastQandAUpdateTimeKey = "lastQandAUpdateTimeKey"

  let initialPageNumber = 1
  var questions = [QuestionUIModel]()
  var targetPage = 0
  var noMorePage = false
  var isFetching = false

  override func viewDidLoad() {
    super.viewDidLoad()

    targetPage = initialPageNumber
    configureRefreshControl()
  }

  private func configureRefreshControl() {
    let lastUpdateTime = NSUserDefaults.standardUserDefaults().stringForKey(lastQandAUpdateTimeKey) ?? "下拉刷新"
    refreshControl.tintColor = UIColor.orangeColor()
    refreshControl.attributedTitle = NSAttributedString(string: lastUpdateTime)
    refreshControl.addTarget(
      self,
      action: #selector(QandAViewController.refresh(_:)),
      forControlEvents: .ValueChanged
    )
    tableQuestions.addSubview(refreshControl)
  }

  func refresh(sender: UIRefreshControl) {
    if (isFetching) {
      return
    }
    isFetching = true

    targetPage = initialPageNumber
    questions.removeAll()

    QandAManager.sharedInstance.fetchQuestions(
      targetPage,
      onComplete: { questions, isLast -> Void in
        self.noMorePage = isLast
        self.questions.appendContentsOf(questions)
        self.tableQuestions.reloadData()
        self.tableQuestions.tableFooterView = isLast ? nil : self.loadMoreView
        self.targetPage += 1
      },
      onError: { error in
        self.showNetworkIsBusyAlertView()
      },
      onFinished: {
        self.isFetching = false

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let updateString = "上次更新時間：" + dateFormatter.stringFromDate(NSDate())
        NSUserDefaults.standardUserDefaults().setObject(updateString, forKey: self.lastQandAUpdateTimeKey)

        self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
        if (self.refreshControl.refreshing) {
          self.refreshControl.endRefreshing()
        }
      }
    )
  }


  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.title = "美食問與答"
    fetchQuestions()
  }

  private func fetchQuestions() {
    if (isFetching) {
      return
    }
    isFetching = true
    tableQuestions.tableFooterView = loadMoreView

    QandAManager.sharedInstance.fetchQuestions(
      targetPage,
      onComplete: { questions, isLast -> Void in
        self.noMorePage = isLast
        self.questions.appendContentsOf(questions)
        self.tableQuestions.reloadData()
        self.tableQuestions.tableFooterView = isLast ? nil : self.loadMoreView
        self.targetPage += 1
      },
      onError: { error in
        self.showNetworkIsBusyAlertView()
      },
      onFinished: {
        self.isFetching = false
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

extension QandAViewController: UITableViewDelegate {

  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if (decelerate) {
      return
    }

    if (scrollView.hasReachedBottom()) {
      loadMoreQuestions()
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if (scrollView.hasReachedBottom()) {
      loadMoreQuestions()
    }
  }

  private func loadMoreQuestions() {
    if (noMorePage) {
      return
    }
    fetchQuestions()
  }

}

extension UIScrollView {

  func hasReachedBottom() -> Bool {
    let bottomEdge = self.contentOffset.y + self.frame.size.height;
    if (bottomEdge >= self.contentSize.height) {
      return true
    }
    return false
  }

}

