//
//  DailyContentTableViewCell.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit
import AVFAudio

class DailyContentTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    static let CellIndentifier = "DailyContentTableViewCell"
    
    typealias ButtonCallBack  = (_ cell: DailyContentTableViewCell) -> Void
    var buttonCallBack: ButtonCallBack?
    var filePath: String = ""
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var bubbleButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bubbleButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func touchUpInsideRecordButton(_ sender: Any) {
        if let callBack = buttonCallBack {
            callBack(self)
        }
    }
    
}
