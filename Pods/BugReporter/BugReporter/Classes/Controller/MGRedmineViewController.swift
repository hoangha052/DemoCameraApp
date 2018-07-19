//
//  MGRedmineViewController.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/12/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import UIKit
import PKHUD

final class MGRedmineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var isIncludedAPIInfo = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        MGRedmineIssue.initProjectID()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    private func configureUI() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        self.title = "Redmine Issue"
        
    }
    
    
    @IBAction func onSendButtonTapped(_ sender: Any) {
        guard MGRedmineIssue.shared.subject.trimmingCharacters(in: .whitespaces) != "" else { MGRedmineAlert.show(message: "Subject must not be empty"); return }
        let issueDescription = isIncludedAPIInfo ? MGRedmineIssue.shared.description + "\n" + MGRedmineLogging.lastestAPIInfo: MGRedmineIssue.shared.description
        let subject = "[\(MGRedmineManager.sharedInstance.projectName) - IOS] \(MGRedmineIssue.shared.subject)"
        
        var params = [
            "subject": subject,
            "priority_id": MGRedmineIssue.shared.priority.rawValue + 1,
            "description": issueDescription
        ] as [String: AnyObject]

        params["project_id"] = MGRedmineIssue.shared.projectID as AnyObject
        MGRedmineAPI.uploadIssueWithImage(image: MGRedmineIssue.shared.screenshot, params: params)
    }

    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TableViewDelegate
extension MGRedmineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedmineInfoCell") as! MGRedmineInfoCell
            cell.delegate = self
            cell.configureUI()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedmineDescriptionCell") as! MGRedmineDescriptionCell
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - MGRedmineCellDelegate
extension MGRedmineViewController: MGRedmineInfoCellDelegate, MGRedmineDescriptionCellDelegate {
    func didTapPriority() {
        MGRedmineDetailViewController.show(presentingViewController: self, detailType: .priority)
    }
    
    func didTapParentTask() {
        MGRedmineDetailViewController.show(presentingViewController: self, detailType: .task)
    }
    
    func didTapAssignee() {
        MGRedmineDetailViewController.show(presentingViewController: self, detailType: .assignee)
    }

    func didSetIncludeAPIInfo(isIncluded: Bool) {
        self.isIncludedAPIInfo = isIncluded
    }
}

