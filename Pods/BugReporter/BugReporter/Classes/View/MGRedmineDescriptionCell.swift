//
//  MGRedmineDescriptionCell.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/12/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import UIKit

protocol MGRedmineDescriptionCellDelegate: class {
    func didSetIncludeAPIInfo(isIncluded: Bool)
}

final class MGRedmineDescriptionCell: UITableViewCell {

    @IBOutlet weak var apiInfoSwitch: UISwitch!
    @IBOutlet weak var textView: UITextView!
    weak var delegate: MGRedmineDescriptionCellDelegate?
    
    @IBAction func onApiInfoSwitchChanged(_ sender: Any) {
        self.delegate?.didSetIncludeAPIInfo(isIncluded: apiInfoSwitch.isOn)
    }
}

extension MGRedmineDescriptionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        MGRedmineIssue.shared.description = textView.text
    }
}
