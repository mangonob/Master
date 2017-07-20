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
    var backgroundColor: UIColor = .red
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
    private (set) lazy var topScrollView = UIScrollView()
    fileprivate lazy var pageContainer = UIView()
    private (set) lazy var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private lazy var indicatorBarView = UIView()
    
    weak var delegate: CLSliderPageControllerDelegate?
    weak var dataSource: CLSliderPageControllerDataSource?
    
    private (set) var defaultTopHeight: CGFloat = 40
    
    private var defaultHighlightedTextColor = UIColor.black
    private var defaultNormalTextColor = UIColor.darkGray
    
    private var defaultHighlightedFont = UIFont.boldSystemFont(ofSize: 16)
    private var defaultNormalFont = UIFont.systemFont(ofSize: 16)
    
    private var defaultHighlightedBackgroundColor = UIColor.white
    private var defaultNormalBackgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    private lazy var buttons = [UIButton]()
    
    private var isSetSelectedIndexAnimatedEnable = false
    
    var selectedIndex: Int = 0 {
        didSet {
            if let vc = viewControllers[selectedIndex] {
                pageController.setViewControllers([vc], direction: selectedIndex > oldValue ? .forward : .reverse, animated: isSetSelectedIndexAnimatedEnable, completion: nil)
            }
            
            let attribute = attributes[selectedIndex]
            UIView.animate(withDuration: isSetSelectedIndexAnimatedEnable ? 0.25 : 0) { [weak self] in
                self?.indicatorBarView.frame = self?.contentView.convert(attribute.frame, from: self?.buttons[self!.selectedIndex]) ?? .zero
                self?.indicatorBarView.backgroundColor = attribute.backgroundColor
                self?.indicatorBarView.alpha = attribute.alpha
                self?.indicatorBarView.transform = attribute.transform
            }
        }
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
            _normalTextColors = [UIColor](repeating: defaultNormalTextColor, count: number)
            
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
            _highlightedTextColors = [UIColor](repeating: defaultHighlightedTextColor, count: number)
            
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
            _normalBackgroundColors = [UIColor](repeating: defaultNormalBackgroundColor, count: number)
            
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
            _highlightedBackgroundColors = [UIColor](repeating: defaultHighlightedBackgroundColor, count: number)
            
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
            _normalFonts = [UIFont](repeating: defaultNormalFont, count: number)
            
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
            _highlightedFonts = [UIFont](repeating: defaultHighlightedFont, count: number)
            
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
            let buttons = (0..<number).map { _ in UIButton() }
            
            zip(buttons, normalTitles).forEach { $0.0.setTitle($0.1, for: .normal) }
            let normalSizes = buttons.map { $0.systemLayoutSizeFitting(.zero) }
            
            zip(buttons, highlightTitles).forEach { $0.0.setTitle($0.1, for: .normal) }
            let highlightSizes = buttons.map { $0.systemLayoutSizeFitting(.zero) }
            
            _originalSizes = zip(normalSizes, highlightSizes).map { $0.0.width > $0.1.width ? $0.0 : $0.1 }
            assert(_originalSizes.count >= number, "\(Date()) Not enough size \(#function):\(#line)")
        }
        
        return _originalSizes
    }
    
    private var _fitSizes: [CGSize]!
    var fitSizes: [CGSize] {
        if _fitSizes == nil {
            _fitSizes = originalSizes
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
        }
        
        if let maxHeight = _fitSizes.map({ $0.height }).max() {
            _fitSizes = _fitSizes.map { CGSize(width: $0.width, height: max(maxHeight, defaultTopHeight)) }
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
                    .divided(atDistance: 4, from: .maxYEdge).slice
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
        _fitSizes = nil
        _recommendAttributes = nil
        _attributes = nil
        
        
        _highlightedTextColors = nil
        _normalTextColors = nil
        
        _highlightedBackgroundColors = nil
        _normalBackgroundColors = nil
        
        _highlightedFonts = nil
        _normalFonts = nil
        
        let contentSize = CGSize(width: fitSizes.map{ $0.width }.reduce(0) { CGFloat($0.0) + $0.1 }, height: fitSizes.first?.height ?? 0)
        var remainderRect = CGRect(origin: .zero, size: contentSize)
        contentView.frame = remainderRect
        topScrollView.contentSize = contentSize
        
        while buttons.count > number { buttons.removeLast() }
        while buttons.count < number { buttons.append(
            {
                let button = UIButton()
                contentView.addSubview(button)
                button.addTarget(self, action: #selector(self.buttonCheckedAction(sender:)), for: .touchUpInside)
                return button
            }()
        ) }
        
        assert(buttons.count == number, "\(Date()) Not correct number of button \(#function) \(#line)")
        
        zip(buttons, normalTitles).forEach { $0.0.setTitle($0.1, for: .normal) }
        
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
        pageController.dataSource = self
        pageController.delegate = self
        
        indicatorBarView.frame = .zero
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
        
        view.backgroundColor = .white
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonCheckedAction(sender: UIButton) {
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


extension CLSliderPageController: UIPageViewControllerDelegate {
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








































