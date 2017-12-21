//
//  CCBanner.swift
//  Demo
//
//  Created by 高炼 on 2017/12/18.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit

private let kCCBannerCellReuseIdentifier = "CCBannerCell"

class CCBanner: UIControl {
    deinit {
        self.collectionView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    var images: [UIImage?] = [#imageLiteral(resourceName: "image_0"), #imageLiteral(resourceName: "image_1"), #imageLiteral(resourceName: "image_2")]
    {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var isCircular: Bool = true {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var _currentIndex: Int = 0
    fileprivate (set) var currentIndex: Int {
        get {
            return _currentIndex
        }
        set {
            _currentIndex = newValue
        }
    }
    
    private var _collectionView: UICollectionView!
    var collectionView: UICollectionView {
        if _collectionView == nil {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            
            _collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
            _collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(_collectionView)
            
            _collectionView.delegate = self
            _collectionView.dataSource = self
            _collectionView.register(CCBannerCell.self, forCellWithReuseIdentifier: kCCBannerCellReuseIdentifier)
            
            _collectionView.backgroundColor = UIColor.clear
            _collectionView.isPagingEnabled = true
            _collectionView.showsHorizontalScrollIndicator = false
            
            _collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.initial, .new], context: nil)
        }
        
        return _collectionView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard isCircular else { return }
        guard images.count > 0 else { return }
        guard let offset = (change?[NSKeyValueChangeKey.newKey] as? CGPoint)?.x else { return }
        
        switch offset {
        case 0..<bounds.width:
            collectionView.contentOffset = CGPoint(x: offset + CGFloat(images.count) * bounds.width, y: 0)
        case (bounds.width * CGFloat(images.count + 1))..<CGFloat.infinity:
            collectionView.contentOffset = CGPoint(x: offset - CGFloat(images.count) * bounds.width, y: 0)
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        collectionView.reloadData()
    }
    
    override var contentMode: UIViewContentMode {
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate var firstDisplayCell = true
}


extension CCBanner: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if firstDisplayCell {
            firstDisplayCell = false
            if (isCircular) {
                collectionView.contentOffset = CGPoint(x: bounds.width, y: 0)
            }
        }
    }
}

extension CCBanner: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}

extension CCBanner: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isCircular ? images.count + 2 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCCBannerCellReuseIdentifier, for: indexPath) as! CCBannerCell
        cell.contentMode = contentMode
        
        if isCircular {
            switch indexPath.row {
            case 0:
                cell.imageView.image = images[images.count - 1]
            case images.count + 1:
                cell.imageView.image = images[0]
            default:
                cell.imageView.image = images[indexPath.row - 1]
            }
        } else {
            cell.imageView.image = images[indexPath.row]
        }
        return cell
    }
}


fileprivate class CCBannerCell: UICollectionViewCell {
    private var _imageView: UIImageView!
    var imageView: UIImageView {
        if _imageView == nil {
            _imageView = UIImageView(frame: contentView.bounds)
            _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(_imageView)
            
            _imageView.clipsToBounds = true
        }
        
        return _imageView
    }
    
    override var contentMode: UIViewContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
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
    }
}
