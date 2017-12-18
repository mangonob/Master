//
//  CCBanner.swift
//  Demo
//
//  Created by 高炼 on 2017/12/18.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

private let CDBannerCellReuseIdentifier = "CCBannerCell"

class CCBanner: UIControl {
    private var _tableView: UITableView!
    var tableView: UITableView {
        if _tableView == nil {
            _tableView = UITableView(frame: bounds, style: .plain)
            _tableView.separatorStyle = .none
            
            _tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(_tableView)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            
            
            if #available(iOS 11.0, *) {
                _tableView.contentInsetAdjustmentBehavior = .never
            }
            
            _tableView.isPagingEnabled = true
            _tableView.showsVerticalScrollIndicator = false
        }
        
        return _tableView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        tableView.register(CCBannerCell.self, forCellReuseIdentifier: CDBannerCellReuseIdentifier)
    }
}

extension CCBanner: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return bounds.height
    }
}


extension CCBanner: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CDBannerCellReuseIdentifier, for: indexPath) as! CCBannerCell
        return cell
    }
}


fileprivate class CCBannerCell: UITableViewCell {
    private var _imageView: UIImageView!
    var mImageView: UIImageView {
        if _imageView == nil {
            _imageView = UIImageView(frame: contentView.bounds)
            _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            _imageView.clipsToBounds = true
            contentView.addSubview(_imageView)
        }
        
        return _imageView
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        configure()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        mImageView.image = #imageLiteral(resourceName: "image_0")
    }
}
