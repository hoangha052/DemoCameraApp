//
//  MGRedminePriorityCell.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/27/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import UIKit

class MGRedminePriorityCell: UITableViewCell {
    private let prioritiesLabel = ["Low", "Normal", "High", "Urgent", "Immediate"]
    @IBOutlet weak var titleLabel: UILabel!
    
    func configureUI(row: Int) {
        self.titleLabel.text = prioritiesLabel[row]
        guard let priority = MGRedminePriority(rawValue: row) else { return }
        self.accessoryType = MGRedmineIssue.shared.priority == priority ? .checkmark : .none
    }
}
