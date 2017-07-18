//
//  TableViewCell.swift
//  Demo
//
//  Created by 高炼 on 2017/6/19.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

@objc protocol TableViewCellDelegate {
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: TableViewCellDelegate?
    
    override var intrinsicContentSize: CGSize {
        return collectionView.contentSize
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: [.initial, .new], context: nil)
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        invalidateIntrinsicContentSize()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
