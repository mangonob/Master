//
//  ContentController.swift
//  Demo
//
//  Created by 高炼 on 2017/8/30.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


class ContentController: UIViewController, CTTableContent {
    var ctTableContentHeight: CGFloat {
        return 400
    }
    
    weak var ctTableReverseDelegate: CTTableReload?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.randomFlat
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

}
