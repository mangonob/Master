//
//  CDImagesBannerView.swift
//  Demo
//
//  Created by 高炼 on 2017/6/23.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


extension UIView {
    class LayoutHint {
        internal weak var view: UIView!
        internal var attribute: NSLayoutAttribute
        
        init(view: UIView, attribute: NSLayoutAttribute) {
            self.view = view
            self.attribute = attribute
        }
        
        func equal(_ other: LayoutHint, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
            return NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem: other.view, attribute: other.attribute, multiplier: multiplier, constant: constant)
        }
        
        func greaterThanOrEqual(_ other: LayoutHint, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
            return NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .greaterThanOrEqual, toItem: other.view, attribute: other.attribute, multiplier: multiplier, constant: constant)
        }
        
        func lessThanOrEqual(_ other: LayoutHint, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
            return NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .lessThanOrEqual, toItem: other.view, attribute: other.attribute, multiplier: multiplier, constant: constant)
        }
    }
    
    var top: LayoutHint {
        return LayoutHint(view: self, attribute: .top)
    }
    
    var bottom: LayoutHint {
        return LayoutHint(view: self, attribute: .bottom)
    }
    
    var left: LayoutHint {
        return LayoutHint(view: self, attribute: .left)
    }
    
    var right: LayoutHint {
        return LayoutHint(view: self, attribute: .right)
    }
    
    var width: LayoutHint {
        return LayoutHint(view: self, attribute: .width)
    }
    
    var height: LayoutHint {
        return LayoutHint(view: self, attribute: .height)
    }
    
    var centerX: LayoutHint {
        return LayoutHint(view: self, attribute: .centerX)
    }
    
    var centerY: LayoutHint {
        return LayoutHint(view: self, attribute: .centerY)
    }
}

class CDImagesBannerView: UIView {
    @IBInspectable
    var currentImage: UIImage? {
        didSet {
            (pageControl as? CDImagePageControl)?.currentImage = currentImage
        }
    }
    
    @IBInspectable
    var noCurrentImage: UIImage? {
        didSet {
            (pageControl as? CDImagePageControl)?.noCurrentImage = noCurrentImage
        }
    }
    var images = [UIImage?]() {
        didSet {
            pageControl.numberOfPages = images.count
            
            guard images.count != 0 else {
                currentIndex = NSNotFound
                return
            }
            
            currentIndex = 0
        }
    }
    
    private var timer: Timer!
    var isRunning = false {
        didSet {
            if isRunning {
                timer = Timer(timeInterval: 3, target: self, selector: #selector(self.timerAction(sender:)), userInfo: nil, repeats: true)
                RunLoop.main.add(timer, forMode: .commonModes)
                timer.fire()
            } else {
                timer.invalidate()
                timer = nil
            }
        }
    }
    
    override var contentMode: UIViewContentMode {
        get {
            return super.contentMode
        }
        set {
            super.contentMode = contentMode
            imageViews.forEach { $0.contentMode = newValue }
        }
    }
    
    var currentIndex: Int = NSNotFound {
        didSet {
            scrollView.contentOffset = CGPoint(x: bounds.width, y: 0)
            
            guard currentIndex != NSNotFound && images.count > 0 else  { return }
            
            pageControl.currentPage = currentIndex
            
            let prevIndex = (currentIndex + images.count - 1) % images.count
            let nextIndex = (currentIndex + 1) % images.count
            
            imageViews[0].image = images[prevIndex]
            imageViews[1].image = images[currentIndex]
            imageViews[2].image = images[nextIndex]
        }
    }
    
    //MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        contentMode = .scaleAspectFill
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        pageControl.isUserInteractionEnabled = false
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(scrollView)
        addSubview(pageControl)
        
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        imageViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false; scrollView.addSubview($0) }
        imageViews.forEach { $0.clipsToBounds = true }
        
        var horzontalAnchors = imageViews.flatMap { [$0.left, $0.right] }
        horzontalAnchors.insert(left, at: 0)
        horzontalAnchors.append(right)
        
        for idx in 0..<horzontalAnchors.count / 2 {
            addConstraint(horzontalAnchors[idx * 2].equal(horzontalAnchors[idx * 2 + 1]))
        }
        
        _ = imageViews.map { $0.width }.reduce(scrollView.width) { addConstraint($0.equal($1));return $1 }
        _ = imageViews.map { $0.height }.reduce(scrollView.height) { addConstraint($0.equal($1));return $1 }
        _ = imageViews.map { $0.top }.reduce(scrollView.top) { addConstraint($0.equal($1));return $1 }
        _ = imageViews.map { $0.bottom }.reduce(scrollView.bottom) { addConstraint($0.equal($1));return $1 }
        
        addConstraint(imageViews.last!.right.equal(scrollView.right))
        addConstraint(imageViews.first!.left.equal(scrollView.left))
        
        imageViews.forEach { $0.backgroundColor = .clear }
        
        updateConstraints()
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.initial, .new], context: nil)
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    private var isTraced = false
    private var isCarousel = false
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if scrollView.isTracking {
            if !isTraced {
                isTraced = true
            }
        }
        
        guard isTraced || isCarousel else { return }
        
        guard let scroll = object as? UIScrollView, scroll == scrollView && keyPath == "contentOffset" && bounds.width > 0 else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let contentOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint else { return }
        
        guard contentOffset.x == 0 || contentOffset.x == 2 * bounds.width else { return }
        
        guard currentIndex != NSNotFound && images.count > 0 else {
            currentIndex = NSNotFound
            return
        }
        
        if contentOffset.x == 0 {
            currentIndex = (currentIndex + images.count - 1) % images.count
        }
        
        if contentOffset.x == 2 * bounds.width {
            currentIndex = (currentIndex + 1) % images.count
        }
    }
    
    func prevImage() {
        isCarousel = true
        defer { isCarousel = false }
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func nextImage() {
        isCarousel = true
        defer { isCarousel = false }
        
        scrollView.setContentOffset(CGPoint(x: bounds.width * 2, y: 0), animated: true)
    }
    
    func setCurrentIndex(index: Int) {
        currentIndex = index
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCurrentIndex(index: currentIndex)
    }
    
    lazy private (set) var scrollView: UIScrollView = UIScrollView()
    lazy private var imageViews = [UIImageView(), UIImageView(), UIImageView()]
    lazy private (set) var pageControl: UIPageControl = CDImagePageControl()
    
    //MARK: - Action
    func timerAction(sender: Timer) {
        isTraced = true
        nextImage()
    }
}



class CDImagePageControl: UIPageControl {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: distance * CGFloat(numberOfPages - 1) + pageIndicatorSize.width,
                      height: max(60, pageIndicatorSize.height))
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    @IBInspectable
    var currentImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var noCurrentImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var distance: CGFloat = 20 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var pageIndicatorSize = CGSize(width: 8, height: 8) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var currentPage: Int {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var numberOfPages: Int {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.translateBy(x: bounds.midX, y: bounds.midY)
        context.translateBy(x: -distance * CGFloat(numberOfPages - 1) / 2, y: 0)
        
        for i in 0..<numberOfPages {
            if let image = i == currentPage ? currentImage : noCurrentImage {
                image.draw(in: CGRect(origin: CGPoint(x: -pageIndicatorSize.width / 2, y: -pageIndicatorSize.height / 2), size: pageIndicatorSize))
            }
            context.translateBy(x: distance, y: 0)
        }
    }
    
    //MARK: - Configure
    func configure() {
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
        backgroundColor = .clear
        
        setNeedsDisplay()
    }
}









































