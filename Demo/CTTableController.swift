//
//  CTTableController.swift
//  B2B-Seller
//
//  Created by 高炼 on 2017/8/24.
//  Copyright © 2017年 佰益源. All rights reserved.
//

import UIKit


class CTTableViewCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}

@objc protocol CTTableReload {
    @objc optional func ctReloadTable(withContent: CTTableContent)
    var tableView: UITableView { get }
}


@objc protocol CTTableContent {
    var ctTableReverseDelegate: CTTableReload? { get set }
    
    @objc optional var ctTableContentHeight: CGFloat { get }
    @objc optional func ctTableContentDidChange(ctTableContent : UIViewController)
}


@objc protocol CTTableControllerItemDelegate {
    func tableControllerItem(loadContent content: CTTableContent)
    @objc optional func tableControllerItem(loadView: UIView)
    @objc optional func tableControllerItem(loadController: UIViewController)
}


class CTTableController: UIViewController, CTTableReload, CTTableControllerItemDelegate {
    var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    func ctReloadTable(withContent: CTTableContent) {
        let index = items.index { (item) -> Bool in
            if let content = item.content as? NSObject, let with = withContent as? NSObject {
                return content == with
            }
            return false
        }
        
        if let index = index {
            tableView.reloadSections(IndexSet(integer: index), with: .none)
        }
    }
    
    class Item {
        enum Style {
            case controller, view, cell, undefine
        }
        
        weak var delegate: CTTableControllerItemDelegate?
        
        fileprivate var isPrepared = false
        
        private var staticHeight: CGFloat = 44
        
        private (set) var style: Style = .undefine
        
        var content: CTTableContent? {
            return controller as? CTTableContent ?? view as? CTTableContent
        }
        
        private (set) var controllerType: UIViewController.Type?
        private var isFromStoryboard = false
        weak var controller: UIViewController?
        
        var rowHeight: CGFloat {
            return content?.ctTableContentHeight ?? staticHeight
        }
        
        private (set) var viewType: UIView.Type?
        var view: UIView?
        var viewNibName: String?
        
        var cellType: UITableViewCell.Type?
        var cellNibName: String?
        
        init(controllerType: UIViewController.Type, fromStoryboard: Bool = false, rowHeight: CGFloat = 44) {
            style = .controller
            isFromStoryboard = fromStoryboard
            
            self.controllerType = controllerType
   
            staticHeight = rowHeight
        }
        
        init(viewNibName: String, rowHeight: CGFloat = 44) {
            style = .view
            self.viewNibName = viewNibName
            
            staticHeight = rowHeight
        }
        
        init(viewType: UIView.Type, rowHeight: CGFloat = 44) {
            style = .view
            self.viewType = viewType
            
            staticHeight = rowHeight
        }
        
        init(viewNibFromType: UIView.Type, rowHeight: CGFloat = 44) {
            style = .view
            viewNibName = viewNibFromType.pureName
            
            staticHeight = rowHeight
        }
        
        init(cellType: UITableViewCell.Type, rowHeight: CGFloat = 44) {
            style = .cell
            self.cellType = cellType
            
            staticHeight = rowHeight
        }
        
        init(cellNibName: String, rowHeight: CGFloat = 44) {
            style = .cell
            self.cellNibName = cellNibName
            
            staticHeight = rowHeight
        }
        
        init(cellNibFromType: UITableViewCell.Type, rowHeight: CGFloat = 44) {
            style = .cell
            cellNibName = cellNibFromType.pureName
            
            staticHeight = rowHeight
        }
        
        private func cellReuseIdentifier(`for` `class`: UITableViewCell.Type) -> String {
            return "\(`class`.pureName)"
        }
        
        func registerFor(_ tableView: UITableView, bundle: Bundle? = nil) {
            tableView.register(CTTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier(for: CTTableViewCell.self))
            
            if let cellNibName = cellNibName {
                tableView.register(UINib(nibName: cellNibName, bundle: bundle), forCellReuseIdentifier: cellNibName)
            } else if let cellType = cellType {
                tableView.register(cellType, forCellReuseIdentifier: cellType.pureName)
            }
        }
        
        func cellFor(_ tableView: UITableView, indexPath: IndexPath, bundle: Bundle? = .main) -> UITableViewCell {
            switch style {
            case .cell:
                var cell: UITableViewCell? = nil
                
                if let cellType = cellType {
                    cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier(for: cellType),
                                                  for: indexPath)
                } else if let cellNibName = cellNibName {
                    cell = tableView.dequeueReusableCell(withIdentifier: cellNibName, for: indexPath)
                }
                
                if let cell = cell {
                    return cell
                } else {
                    fatalError("Bad cell type of nib name")
                }
            case .view:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier(for: CTTableViewCell.self),
                                                         for: indexPath)
                cell.selectionStyle = .none
                
                if view == nil {
                    var v: UIView?
                    if let viewType = viewType {
                        v = viewType.init()
                    } else if let viewNibName = viewNibName {
                        v = bundle?.loadNibNamed(viewNibName, owner: nil, options: nil)?.first as? UIView
                    }
                    
                    self.view = v
                    v?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    if let content = v as? CTTableContent {
                        delegate?.tableControllerItem(loadContent: content)
                    }
                    
                    if let view = v {
                        delegate?.tableControllerItem?(loadView: view)
                    }
                }
                
                if let view = view {
                    view.frame = cell.contentView.bounds
                    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                    cell.contentView.addSubview(view)
                }
                
                return cell
            case .controller:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier(for: CTTableViewCell.self),
                                         for: indexPath)
                cell.selectionStyle = .none
                
                var newController: UIViewController!
                
                if controller == nil {
                    assert(controllerType != nil, "ControllerType is nil")
                    
                    if let controllerType = controllerType {
                        if isFromStoryboard {
                            newController = controllerType.loadFromStoryBoard()
                        } else {
                            newController = controllerType.init()
                        }
                    }
                    
                    newController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    if let content = newController as? CTTableContent {
                        delegate?.tableControllerItem(loadContent: content)
                    }
                    
                    if let controller = newController {
                        delegate?.tableControllerItem?(loadController: controller)
                        (delegate as? UIViewController)?.addChildViewController(controller)
                    }
                    
                    controller = newController
                }
                
                
                if let view = controller?.view {
                    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                    view.frame = cell.contentView.bounds
                    cell.contentView.addSubview(view)
                }
                
                return cell
            default:
                fatalError("Unexcept CTTableController.Item")
            }
        }
    }
    
    lazy private var _items = [Item]()
    internal var items: [Item] {
        return _items
    }
    
    fileprivate var cookedItems: [Item] {
        let cooked = items
        
        cooked.forEach { (item) in
            if !item.isPrepared {
                prepareForItem(item)
            }
        }
        
        return cooked
    }
    
    func prepareForItem(_ item: Item) {
        item.registerFor(tableView)
        item.delegate = self
    }
    
    private func prepareForItems(_ items: [Item]? = nil) {
        if items == nil {
            self.items.forEach { $0.registerFor(tableView) }
            self.items.forEach { $0.delegate = self }
        } else {
            items?.forEach { $0.registerFor(tableView) }
            items?.forEach { $0.delegate = self }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        
        prepareForItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableControllerItem(loadContent content: CTTableContent) {
        content.ctTableReverseDelegate = self
    }
    
    func tableControllerItem(loadController: UIViewController) {
//        addChildViewController(loadController)
    }
}


extension CTTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cookedItems[indexPath.section].rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
}


extension CTTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cookedItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cookedItems[indexPath.section].cellFor(tableView, indexPath: indexPath)
    }
}
