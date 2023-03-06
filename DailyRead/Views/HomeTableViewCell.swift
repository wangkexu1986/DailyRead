//
//  HomeTableViewCell.swift
//  Daily Read
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    static let CellIndentifier = "HomeTableViewCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
