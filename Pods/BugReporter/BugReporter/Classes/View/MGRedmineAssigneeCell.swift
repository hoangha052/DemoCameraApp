//
//  MGRedmineAssigneeCell.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 12/9/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import UIKit

class MGRedmineAssigneeCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    
    func configureUI(assignee: MGRedmineAssignee) {
        self.nameLabel.text = assignee.name
        self.roleLabel.text = assignee.role
        self.accessoryType = MGRedmineIssue.shared.assignee.id == assignee.id ? .checkmark : .none
    }
}
