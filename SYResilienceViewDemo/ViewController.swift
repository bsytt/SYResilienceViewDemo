//
//  ViewController.swift
//  SYResilienceViewDemo
//
//  Created by bsy on 2019/8/25.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let spaceName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            print("获取命名空间失败")
            return
        }
        let vcStr = pushToNextControllers[indexPath.row]
        let vcClass:AnyClass? = NSClassFromString(spaceName + "." + vcStr)
        let typeClass = vcClass as? UIViewController.Type
        let vc = typeClass!.init()
        self.navigationController?.pushViewController(vc , animated: true)

    }
    
    lazy var pushToNextControllers: [String] = {
        let classArray = ["SYResilienceViewController","SYMineFirstStyleViewController","SYMineSecondStyleViewController"]
        return classArray
    }()
    
}

