//
//  ViewController.swift
//  Demo
//
//  Created by 高炼 on 17/3/27.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct Speaker: CustomStringConvertible {
    let name: String
    let twitterHandle: String
    
    var description: String {
        return "\(name) \(twitterHandle)"
    }
}


struct SpeakerListViewModel {
    let data = Observable.just([
        Speaker(name: "Ben Sandofsky", twitterHandle: "@sandofsky"),
        Speaker(name: "Carla White", twitterHandle: "@carlawhite"),
        Speaker(name: "Jaimee Newberry", twitterHandle: "@jaimeejaimee"),
        Speaker(name: "Natasha Murashev", twitterHandle: "@natashatherobot"),
        Speaker(name: "Robi Ganguly", twitterHandle: "@rganguly"),
        Speaker(name: "Virginia Roberts",  twitterHandle: "@askvirginia"),
        Speaker(name: "Scott Gardner", twitterHandle: "@scotteg"),
        ])
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var sepakerViewModel = SpeakerListViewModel()
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        sepakerViewModel.data.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { (index, speak, cell) in
            cell.textLabel?.text = speak.name
            cell.detailTextLabel?.text = speak.twitterHandle
        }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(Speaker.self)
        .subscribe(onNext: { (speaker) in
            print(speaker)
        })
        .addDisposableTo(disposeBag)
    }
}
