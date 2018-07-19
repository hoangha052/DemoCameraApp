//
//  MGRedmineTaskCell.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 11/16/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import UIKit

class MGRedmineTaskCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    func configureUI(task: MGRedmineTask) {
        subjectLabel.text = task.subject
        authorLabel.text = "Created by: \(task.author)"
        dateCreatedLabel.text = task.createdOn.timeAgoSinceDate()
        self.accessoryType = MGRedmineIssue.shared.parentTaskID == task.id ? .checkmark : .none
    }
}
