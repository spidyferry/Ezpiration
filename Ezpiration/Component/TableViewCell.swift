//
//  TableViewCell.swift
//  Ezpiration
//
//  Created by ferry sugianto on 22/06/21.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var labelTest: UILabel!
    @IBOutlet weak var inspirationCard: UIView!
    @IBOutlet weak var dateRecord: UILabel!
    @IBOutlet weak var recordingTag: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        inspirationCard.layer.cornerRadius = 10
        recordingTag.layer.cornerRadius = 5
        recordingTag.intrinsicContentSize.width 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
