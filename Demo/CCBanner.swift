//
//  CCBanner.swift
//  Demo
//
//  Created by 高炼 on 2017/12/18.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import ChameleonFramework


private let kCCBannerCellReuseIdentifier = "CCBannerCell"

@objc protocol CCBannerPageDrawDelegate {
    @objc optional func bannerDrawPageControl(withContext context: CGContext, rect: CGRect, currentPage page: Int, numberOfPage: Int)
}


fileprivate class CCBannerCoverView: UIView, CCBannerPageDrawDelegate {
    weak var drawDelegate: CCBannerPageDrawDelegate? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var numberOfPage = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var currentPage = NSNotFound {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let currentContext = UIGraphicsGetCurrentContext() {
            (drawDelegate ?? self).bannerDrawPageControl?(withContext: currentContext, rect: rect, currentPage: currentPage, numberOfPage: numberOfPage)
        }
    }
    
    func bannerDrawPageControl(withContext context: CGContext, rect: CGRect, currentPage page: Int, numberOfPage: Int) {
        // Default drawing code
        context.saveGState()
        defer { context.restoreGState() }
        
        let indicatorSize = CGSize(width: 10, height: 2)
        let indicatorSpacing: CGFloat = 8
        
        let bottomRect = rect.divided(atDistance: 40, from: .maxYEdge).slice
        
        var indicatorsRect = CGRect(x: bottomRect.midX, y: bottomRect.midY,
                                    width: indicatorSize.width * CGFloat(numberOfPage) + indicatorSpacing * (CGFloat(numberOfPage) - 1), height: indicatorSize.height)
        
        indicatorsRect.origin.x -= indicatorsRect.width / 2
        indicatorsRect.origin.y -= indicatorsRect.height / 2
        
        for page in 0..<numberOfPage {
            UIColor(hexString: page == currentPage ? "#FF0000" : "#00FF00")?.setFill()
            UIBezierPath(rect: indicatorsRect.divided(atDistance: indicatorSize.width, from: .minXEdge).slice).fill()
            
            indicatorsRect = indicatorsRect.divided(atDistance: indicatorSize.width + indicatorSpacing, from: .minXEdge).remainder
        }
    }
}


class CCBanner: UIControl {
    weak var drawDelegate: CCBannerPageDrawDelegate?
    {
        didSet {
            pageCover.drawDelegate = drawDelegate
            pageCover.setNeedsDisplay()
        }
    }
    
    deinit {
        self.collectionView.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentOffset))
        self.collectionView.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize))
    }
    
    var images: [UIImage?] = [#imageLiteral(resourceName: "image_1"), #imageLiteral(resourceName: "image_2"), #imageLiteral(resourceName: "image_3")]
    {
        didSet {
            collectionView.reloadData()
            pageCover.numberOfPage = images.count
        }
    }
    
    var isCircular: Bool = true {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var currentIndex: Int {
        get {
            let offset = collectionView.contentOffset.x
            return Int(offset / bounds.width + 0.5) % images.count
        }
        set {
            guard currentIndex > 0 && currentIndex < images.count else {
                fatalError("Index out of range")
            }
            
            pageCover.currentPage = newValue
        }
    }
    
    private var _pageCover: CCBannerCoverView!
    private var pageCover: CCBannerCoverView {
        if _pageCover == nil {
            _pageCover = CCBannerCoverView()
            _pageCover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            _pageCover.backgroundColor = UIColor.clear
            _pageCover.frame = bounds
            _pageCover.isUserInteractionEnabled = false
            addSubview(_pageCover)
        }
        return _pageCover
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
            
            _collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentOffset), options: [.initial, .new], context: nil)
            _collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: [.initial, .new], context: nil)
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
        
        let offset = (change?[NSKeyValueChangeKey.newKey] as? CGPoint)?.x ?? collectionView.contentOffset.x
        
        switch offset {
        case 0..<bounds.width:
            collectionView.contentOffset = CGPoint(x: offset + CGFloat(images.count) * bounds.width, y: 0)
        case (bounds.width * CGFloat(images.count + 1))..<CGFloat.infinity:
            collectionView.contentOffset = CGPoint(x: offset - CGFloat(images.count) * bounds.width, y: 0)
        default:
            break
        }
        
        if pageCover.currentPage != currentIndex {
            pageCover.currentPage = currentIndex
            print(currentIndex)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        collectionView.reloadData()
        pageCover.drawDelegate = drawDelegate
        pageCover.numberOfPage = images.count
    }
    
    override var contentMode: UIViewContentMode {
        didSet {
            collectionView.reloadData()
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
        if images.isEmpty {
            return 0
        }
        
        return isCircular ? images.count + 2 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCCBannerCellReuseIdentifier, for: indexPath) as! CCBannerCell
        cell.contentMode = contentMode
        
        if isCircular {
            switch indexPath.row {
            case 0..<images.count:
                cell.imageView.image = images[indexPath.row]
            case images.count:
                if images.count > 0 {
                    cell.imageView.image = images[0]
                }
            case images.count + 1:
                if images.count > 1 {
                    cell.imageView.image = images[1]
                } else if images.count > 0 {
                    cell.imageView.image = images[0]
                }
            default:
                break
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
