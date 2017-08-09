//
//  CLSliderPageController.swift
//  Demo
//
//  Created by 高炼 on 2017/7/19.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


class CLSliderPageIndicatorAttribute: NSObject {
    var frame: CGRect = .zero
    var backgroundColor: UIColor?
    fileprivate (set) var parentSize: CGSize = .zero
    fileprivate (set) var contentSize: CGSize = .zero
    var alpha: CGFloat = 1
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    override func copy() -> Any {
        let r = CLSliderPageIndicatorAttribute()
        r.frame = frame
        r.backgroundColor = backgroundColor
        r.parentSize = parentSize
        r.contentSize = contentSize
        r.alpha = alpha
        r.transform = transform
        return r
    }
    
    override func mutableCopy() -> Any {
        return copy()
    }
}

@objc protocol CLSliderPageControllerDelegate {
}


@objc protocol CLSliderPageControllerDataSource {
    @objc func sliderPageController(_ controller: CLSliderPageController, viewControllerAt index: Int) -> UIViewController?
    @objc func numberOfPages(in controller: CLSliderPageController) -> Int
    
    @objc optional func sliderPageController(_ controller: CLSliderPageController, titleForPageAt index: Int, highlighted: Bool) -> String?
    
    @objc optional func sliderPageController(_ controller: CLSliderPageController, fontOfButtonAt index: Int, highlighted: Bool) -> UIFont?
    
    @objc optional func sliderPageController(_ controller: CLSliderPageController, backgroundColorOfButtonAt index: Int, highlighted: Bool) -> UIColor?
    
    @objc optional func sliderPageController(_ controller: CLSliderPageController, textColorOfButtonAt index: Int, highlighted: Bool) -> UIColor?
    
    @objc optional func sliderPageController(_ controller: CLSliderPageController, sizeOfButtonAt index: Int, withContentSize size: CGSize) -> CGSize
    
    @objc optional func sliderPageController(_ controller: CLSliderPageController, attributeOfIndicatorAt index: Int, withRecommendAttribute attribute: CLSliderPageIndicatorAttribute) -> CLSliderPageIndicatorAttribute?
}

class CLSliderPageController: UIViewController {
    private let defaultIndicatorBarHeight: CGFloat = 4
    
    private (set) lazy var topScrollView = UIScrollView()
    fileprivate lazy var pageContainer = UIView()
    private (set) lazy var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private (set) lazy var indicatorBarView = UIView()
    
    weak var delegate: CLSliderPageControllerDelegate?
    weak var dataSource: CLSliderPageControllerDataSource?
    
    private (set) var defaultTopHeight: CGFloat = 40
    
    var indicatorBarColor: UIColor? {
        didSet {
            if let color = indicatorBarColor {
                indicatorBarView.backgroundColor = color
            }
        }
    }
    
    private var defaultIndicatorBarColor = UIColor(colorLiteralRed: 64/255.0, green: 176/255.0, blue: 231/255.0, alpha: 1)
    private var defaultHighlightedTextColor = UIColor(colorLiteralRed: 64/255.0, green: 176/255.0, blue: 231/255.0, alpha: 1)
    private var defaultNormalTextColor = UIColor.lightGray
    
    private var defaultHighlightedFont = UIFont.boldSystemFont(ofSize: 16)
    private var defaultNormalFont = UIFont.systemFont(ofSize: 16)
    
    private var defaultHighlightedBackgroundColor = /* UIColor.lightGray.withAlphaComponent(0.5) */ UIColor.clear
    private var defaultNormalBackgroundColor = UIColor.white
    
    private lazy var _buttons = [UIButton]()
    internal var buttons: [UIButton] {
        while _buttons.count > number { _buttons.removeLast() }
        while _buttons.count < number { _buttons.append(
            {
                let button = UIButton()
                contentView.insertSubview(button, at: 0)
                button.addTarget(self, action: #selector(self.buttonCheckedAction(sender:)), for: .touchUpInside)
                return button
            }()
            ) }
        
        assert(_buttons.count == number, "\(Date()) Not correct number of button \(#function) \(#line)")
        
        return _buttons
    }
    
    
    private var isSetSelectedIndexAnimatedEnable = false
    private var isShouldChangeViewControllerWhenSelecedIndex = true
    fileprivate var isLastButtonInteraction = false
    
    var selectedIndex: Int = 0 {
        didSet {
            if let vc = viewControllers[selectedIndex], isShouldChangeViewControllerWhenSelecedIndex {
                pageController.setViewControllers([vc], direction: selectedIndex > oldValue ? .forward : .reverse, animated: isSetSelectedIndexAnimatedEnable, completion: nil)
            }
            
            let attribute = attributes[selectedIndex]
            UIView.animate(withDuration: isSetSelectedIndexAnimatedEnable ? 0.25 : 0, animations: { [weak self] in
                self?.indicatorBarView.frame = self?.contentView.convert(attribute.frame, from: self?.buttons[self!.selectedIndex]) ?? .zero
                self?.indicatorBarView.backgroundColor = attribute.backgroundColor ?? self?.indicatorBarColor ?? self?.defaultIndicatorBarColor
                self?.indicatorBarView.alpha = attribute.alpha
                self?.indicatorBarView.transform = attribute.transform
            })
            
            let reset = (topScrollView.bounds.width - buttons[selectedIndex].bounds.width) / 2
            topScrollView.scrollRectToVisible(buttons[selectedIndex].frame.insetBy(dx: -reset, dy: 0), animated: true)
            
            updateButtonsStyle()
        }
    }
    
    fileprivate func setSelectIndexWithOutChangeViewCotroller(_ index: Int) {
        isShouldChangeViewControllerWhenSelecedIndex = false
        
        selectedIndex = index
        
        isShouldChangeViewControllerWhenSelecedIndex = true
    }
    
    func setSelectedIndex(index: Int, animated: Bool) {
        isSetSelectedIndexAnimatedEnable = animated
        
        selectedIndex = index
        
        isSetSelectedIndexAnimatedEnable = false
    }
    
    var highlightedTextColor: UIColor? {
        didSet {
        }
    }
    
    var normalTextColor: UIColor?
    
    var highlightedFont: UIFont? {
        didSet {
        }
    }
    
    var normalFont: UIFont? {
        didSet {
        }
    }
    
    var highlightedBackgroundColor: UIColor?
    var normalBackgroundColor: UIColor?
    
    private var _normalTextColors: [UIColor]!
    internal var normalTextColors: [UIColor] {
        if _normalTextColors == nil {
            _normalTextColors = [UIColor](repeating: normalTextColor ?? defaultNormalTextColor, count: number)
            
            for i in 0..<number {
                if let color = dataSource?.sliderPageController?(self, textColorOfButtonAt: i, highlighted: false) {
                    _normalTextColors[i] = color
                }
            }
        }
        
        return _normalTextColors
    }
    
    private var _highlightedTextColors: [UIColor]!
    internal var highlightedTextColors: [UIColor] {
        if _highlightedTextColors == nil {
            _highlightedTextColors = [UIColor](repeating: highlightedTextColor ?? defaultHighlightedTextColor, count: number)
            
            for i in 0..<number {
                if let color = dataSource?.sliderPageController?(self, textColorOfButtonAt: i, highlighted: true) {
                    _highlightedTextColors[i] = color
                }
            }
        }
        
        return _highlightedTextColors
    }
    
    private var _normalBackgroundColors: [UIColor]!
    internal var normalBackgroundColors: [UIColor] {
        if _normalBackgroundColors == nil {
            _normalBackgroundColors = [UIColor](repeating: normalBackgroundColor ?? defaultNormalBackgroundColor, count: number)
            
            for i in 0..<number {
                if let color = dataSource?.sliderPageController?(self, backgroundColorOfButtonAt: i, highlighted: false) {
                    _normalBackgroundColors[i] = color
                }
            }
        }
        
        return _normalBackgroundColors
    }
    
    private var _highlightedBackgroundColors: [UIColor]!
    internal var highlightedBackgroundColors: [UIColor] {
        if _highlightedBackgroundColors == nil {
            _highlightedBackgroundColors = [UIColor](repeating: highlightedBackgroundColor ?? defaultHighlightedBackgroundColor, count: number)
            
            for i in 0..<number {
                if let color = dataSource?.sliderPageController?(self, backgroundColorOfButtonAt: i, highlighted: true) {
                    _highlightedBackgroundColors[i] = color
                }
            }
        }
        
        return _highlightedBackgroundColors
    }
    
    private var _normalFonts: [UIFont]!
    internal var normalFonts: [UIFont] {
        if _normalFonts == nil {
            _normalFonts = [UIFont](repeating: normalFont ?? defaultNormalFont, count: number)
            
            for i in 0..<number {
                if let font = dataSource?.sliderPageController?(self, fontOfButtonAt: i, highlighted: false) {
                    _normalFonts[i] = font
                }
            }
        }
        
        return _normalFonts
    }
    
    private var _highlightedFonts: [UIFont]!
    internal var highlightedFonts: [UIFont] {
        if _highlightedFonts == nil {
            _highlightedFonts = [UIFont](repeating: highlightedFont ?? defaultHighlightedFont, count: number)
            
            for i in 0..<number {
                if let font = dataSource?.sliderPageController?(self, fontOfButtonAt: i, highlighted: true) {
                    _highlightedFonts[i] = font
                }
            }
        }
        
        return _highlightedFonts
    }
    
    private var _contentView: UIView!
    internal var contentView: UIView {
        if _contentView == nil {
            _contentView = UIView()
            topScrollView.addSubview(_contentView)
        }
        
        return _contentView
    }
    
    internal var topContentSize: CGSize = .zero {
        didSet {
            contentView.frame = CGRect(origin: .zero, size: topContentSize)
            topScrollView.contentSize = topContentSize
        }
    }
    
    var titles: [String]? {
        didSet {
            reloadData()
        }
    }
    
    private var _viewControllers: [UIViewController?]!
    var viewControllers: [UIViewController?] {
        if _viewControllers == nil {
            _viewControllers = (0..<(dataSource?.numberOfPages(in: self) ?? 0))
                .map { dataSource?.sliderPageController(self, viewControllerAt: $0) }
        }
        
        return _viewControllers
    }
    
    private var number: Int {
        return dataSource?.numberOfPages(in: self) ?? self.titles?.count ?? 0
    }
    
    private var _normalTitles: [String]!
    private var normalTitles: [String] {
        if _normalTitles == nil {
            _normalTitles = self.titles ?? []
            
            for i in 0..<number {
                if let title = dataSource?.sliderPageController?(self, titleForPageAt: i, highlighted: false) {
                    if i < _normalTitles.count {
                        _normalTitles[i] = title
                    } else {
                        _normalTitles.append(title)
                    }
                }
            }
            
            while _normalTitles.count < number { _normalTitles.append("Untitled") }
            assert(_normalTitles.count >= number, "\(Date()) Not enough normal title \(#function)")
        }
        
        return _normalTitles
    }
    
    private var _highlightTitles: [String]!
    var highlightTitles: [String] {
        if _highlightTitles == nil {
            _highlightTitles = normalTitles
            for i in 0..<number {
                if let title = dataSource?.sliderPageController?(self, titleForPageAt: i, highlighted: true) {
                    if i < _highlightTitles.count {
                        _highlightTitles[i] = title
                    } else {
                        _highlightTitles.append(title)
                    }
                }
            }
            
            while _highlightTitles.count < number { _highlightTitles.append("Untitled") }
            assert(_highlightTitles.count >= number, "\(Date()) Not enough highlight title \(#function):\(#line)")
        }
        
        return _highlightTitles
    }
    
    private var _originalSizes: [CGSize]!
    var originalSizes: [CGSize] {
        if _originalSizes == nil {
            updateButtonsStyle()
            
            zip(buttons, normalTitles).forEach { $0.0.setTitle($0.1, for: .normal) }
            let normalSizes = buttons.map { $0.systemLayoutSizeFitting(.zero) }
            
            zip(buttons, highlightTitles).forEach { $0.0.setTitle($0.1, for: .normal) }
            let highlightSizes = buttons.map { $0.systemLayoutSizeFitting(.zero) }
            
            _originalSizes = zip(normalSizes, highlightSizes).map { $0.0.width > $0.1.width ? $0.0 : $0.1 }
            assert(_originalSizes.count >= number, "\(Date()) Not enough size \(#function):\(#line)")
        }
        
        return _originalSizes
    }
    
    var fitSizes: [CGSize] {
        var _fitSizes = originalSizes
        
        for i in 0..<number {
            var originalSize = _fitSizes[i]
            if let size = dataSource?.sliderPageController?(self, sizeOfButtonAt: i, withContentSize: originalSize) {
                originalSize = size
            } else {
                originalSize.width += 32
                originalSize.height += 16
            }
            _fitSizes[i] = originalSize
        }
        
        if let maxHeight = _fitSizes.map({ $0.height }).max() {
            _fitSizes = _fitSizes.map { CGSize(width: $0.width, height: max(maxHeight, defaultTopHeight)) }
        }
        
        let totalWidth = _fitSizes.reduce(0) { $0.0 + $0.1.width }
        
        if totalWidth < view.bounds.width && totalWidth > 0 {
            _fitSizes = _fitSizes.map { CGSize(width: $0.width * (view.bounds.width / totalWidth), height: $0.height) }
        }
        
        return _fitSizes
    }
    
    private var _recommendAttributes: [CLSliderPageIndicatorAttribute]!
    private var recommendAttributes: [CLSliderPageIndicatorAttribute] {
        if _recommendAttributes == nil {
            _recommendAttributes = (0..<number).map { _ in CLSliderPageIndicatorAttribute() }
            
            for (attribute, (fitSize, originalSize)) in zip(_recommendAttributes, zip(fitSizes, originalSizes)) {
                attribute.contentSize = originalSize
                attribute.parentSize = fitSize
                let margin = max((fitSize.width - originalSize.width) / 2, 0)
                
                attribute.frame = CGRect(origin: .zero, size: fitSize)
                    .divided(atDistance: defaultIndicatorBarHeight, from: .maxYEdge).slice
                    .divided(atDistance: margin, from: .minXEdge).remainder
                    .divided(atDistance: margin, from: .maxXEdge).remainder
            }
        }
        return _recommendAttributes
    }
    
    private var _attributes: [CLSliderPageIndicatorAttribute]!
    private var attributes: [CLSliderPageIndicatorAttribute] {
        if _attributes == nil {
            _attributes = recommendAttributes
            _attributes.map { $0.copy() as! CLSliderPageIndicatorAttribute }
                .enumerated()
                .forEach { (i, attrib) in
                    if let attribute = dataSource?.sliderPageController?(self, attributeOfIndicatorAt: i, withRecommendAttribute: attrib) {
                        _attributes[i] = attribute
                    }
            }
        }
        
        return _attributes
    }
    
    func reloadData() {
        _viewControllers = nil
        _normalTitles = nil
        _highlightTitles = nil
        _originalSizes = nil
        _recommendAttributes = nil
        _attributes = nil
        
        _highlightedTextColors = nil
        _normalTextColors = nil
        
        _highlightedBackgroundColors = nil
        _normalBackgroundColors = nil
        
        _highlightedFonts = nil
        _normalFonts = nil
        
        let contentSize = CGSize(width: fitSizes.reduce(0) { $0.0 + $0.1.width }, height: fitSizes.first?.height ?? 0)
        var remainderRect = CGRect(origin: .zero, size: contentSize)
        contentView.frame = remainderRect
        topScrollView.contentSize = contentSize
        
        zip(buttons, normalTitles).forEach {
            $0.0.setTitle($0.1, for: .normal)
        }
        
        zip(buttons, fitSizes).forEach {
            $0.0.frame = remainderRect.divided(atDistance: $0.1.width, from: .minXEdge).slice
            remainderRect = remainderRect.divided(atDistance: $0.1.width, from: .minXEdge).remainder
        }
        
        updateComponentLayout()
        
        updateButtonsStyle()
        
        selectedIndex = max(min(selectedIndex, number - 1), 0)
    }
    
    private func updateComponentLayout() {
        let height =  fitSizes.first?.height ?? defaultTopHeight
        
        topScrollView.frame = view.bounds.divided(atDistance: height, from: .minYEdge).slice
        pageContainer.frame = view.bounds.divided(atDistance: height, from: .minYEdge).remainder
    }
    
    private func updateButtonsStyle() {
        buttons.enumerated().forEach { (i, button) in
            if i == selectedIndex {
                button.titleLabel?.font = highlightedFonts[i]
                button.backgroundColor = highlightedBackgroundColors[i]
                button.setTitleColor(highlightedTextColors[i], for: .normal)
            } else {
                button.titleLabel?.font = normalFonts[i]
                button.backgroundColor = normalBackgroundColors[i]
                button.setTitleColor(normalTextColors[i], for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        topScrollView.showsHorizontalScrollIndicator = false
        topScrollView.bounces = false
        
        pageController.dataSource = self
        pageController.delegate = self
        
        indicatorBarView.frame = .zero
        
        indicatorBarView.layer.cornerRadius = defaultIndicatorBarHeight / 2
        
        contentView.addSubview(indicatorBarView)
        
        topScrollView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        pageContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        topScrollView.frame = view.bounds.divided(atDistance: defaultTopHeight, from: .minYEdge).slice
        pageContainer.frame = view.bounds.divided(atDistance: defaultTopHeight, from: .minYEdge).remainder
        
        view.addSubview(topScrollView)
        view.addSubview(pageContainer)
        
        pageController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageController.view.frame = pageContainer.bounds
        pageContainer.addSubview(pageController.view)
        addChildViewController(pageController)
        
        if let queueScrollView = pageController.view.subviews.first as? UIScrollView {
            queueScrollView.addObserver(self, forKeyPath: "contentOffset", options: [.initial, .new], context: nil)
            queueScrollView.delegate = self
        }
        
        view.backgroundColor = .white
        reloadData()
    }
    
    deinit {
        if let queueScrollView = pageController.view.subviews.first as? UIScrollView {
            queueScrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let _ = object as? UIScrollView, let contentOffset = (change?[.newKey] as? NSValue)?.cgPointValue, keyPath == "contentOffset" else { return }
        
        guard !isLastButtonInteraction else { return }
        
        let L = topScrollView.bounds.width
        var progress = (contentOffset.x - L) / L
        
        let currentIndex = selectedIndex
        let nextIndex = currentIndex + (progress > 0 ? 1 : -1)
        
        progress = abs(progress)
        
        if nextIndex >= 0 && nextIndex < number {
            let from = contentView.convert(attributes[currentIndex].frame, from: buttons[currentIndex])
            let to = contentView.convert(attributes[nextIndex].frame, from: buttons[nextIndex])
            
            let current = CGRect(
                x: (to.origin.x - from.origin.x) * progress + from.origin.x,
                y: (to.origin.y - from.origin.y) * progress + from.origin.y,
                width: (to.size.width - from.size.width) * progress + from.size.width,
                height: (to.size.height - from.size.height) * progress + from.size.height
            )
            
            indicatorBarView.frame = current
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonCheckedAction(sender: UIButton) {
        isLastButtonInteraction = true
        guard let index = buttons.index(of: sender) else { return }
        
        setSelectedIndex(index: index, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}


extension CLSliderPageController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentView.isUserInteractionEnabled = false
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isLastButtonInteraction = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            contentView.isUserInteractionEnabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentView.isUserInteractionEnabled = true
    }
}

extension CLSliderPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = (viewControllers.index{ $0 == pageViewController.viewControllers?.first }) {
            setSelectIndexWithOutChangeViewCotroller(index)
        }
    }
}


extension CLSliderPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = (viewControllers.index { (vc) -> Bool in return vc == viewController }) {
            if index - 1 >= 0 && index - 1 < viewControllers.count {
                return viewControllers[index - 1]
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = (viewControllers.index { (vc) -> Bool in return vc == viewController }) {
            if index + 1 >= 0 && index + 1 < viewControllers.count {
                return viewControllers[index + 1]
            } else {
                return nil
            }
        }
        
        return nil
    }
}








































