//
//  TableViewCell.swift
//  Demo
//
//  Created by 高炼 on 2017/6/19.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

@objc protocol TableViewCellDelegate {
    @objc optional func tableViewCellCommit(tableViewCell: TableViewCell)
}

class OtherView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 400)
    }
}

class TableViewCell: UITableViewCell {
    weak var delegate: TableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
