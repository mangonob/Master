//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    lazy var tableView = UITableView(frame: .zero, style: .grouped)
    
    var items = [Int](repeating: 10, count: 26)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollToNearestSelectedRow(at: .middle, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        items[indexPath.section] -= 1
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        tableView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            tableView.isUserInteractionEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".characters.map({ String($0) })[section]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".characters.map { String($0) }
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let view = UIView()
        view.backgroundColor = UIColor.randomFlat
        view.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        cell.accessoryView = view
        cell.showsReorderControl = true
        cell.shouldIndentWhileEditing = false
        cell.textLabel?.text = "AAA"
        return cell
    }
}
