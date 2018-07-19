//
//  MGRedmineInfoCell.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/12/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import UIKit

protocol MGRedmineInfoCellDelegate: class {
    func didTapPriority()
    func didTapParentTask()
    func didTapAssignee()
}

final class MGRedmineInfoCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priorityTextField: UILabel!
    @IBOutlet weak var parentTaskTextField: UILabel!
    @IBOutlet weak var assigneeTextField: UILabel!
    weak var delegate: MGRedmineInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let priorityTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPriorityTapped))
        let parentTaskTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onParentTaskTapped))
        let assigneeTaskRecognizer = UITapGestureRecognizer(target: self, action: #selector(onAssigneeTapped))
        priorityTextField.addGestureRecognizer(priorityTapRecognizer)
        parentTaskTextField.addGestureRecognizer(parentTaskTapRecognizer)
        assigneeTextField.addGestureRecognizer(assigneeTaskRecognizer)
    }
    
    @objc func onPriorityTapped() {
        delegate?.didTapPriority()
    }
    
    @objc func onParentTaskTapped() {
        delegate?.didTapParentTask()
    }
    
    @objc func onAssigneeTapped() {
        delegate?.didTapAssignee()
    }
    
    func configureUI() {
        switch MGRedmineIssue.shared.priority {
        case .low:
            priorityTextField.text = "Low"
        case .normal:
            priorityTextField.text = "Normal"
        case .urgent:
            priorityTextField.text = "Urgent"
        case .high:
            priorityTextField.text = "High"
        case .immediate:
            priorityTextField.text = "Immediate"
        }
        parentTaskTextField.text = MGRedmineIssue.shared.parentTaskID == 0 ? "None" : "#\(MGRedmineIssue.shared.parentTaskID)"
        assigneeTextField.text = MGRedmineIssue.shared.assignee.id == 0 ? "None" : "#\(MGRedmineIssue.shared.assignee.name)"
    }
}

extension MGRedmineInfoCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        MGRedmineIssue.shared.subject = textField.text ?? ""
    }
}

