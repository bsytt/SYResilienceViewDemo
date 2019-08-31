//
//  SYMineChildViewController.swift
//  SYResilienceViewDemo
//
//  Created by 包曙源 on 2019/8/30.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class SYMineChildViewController: UIViewController {

    var type = ""
    var identifier = "MineChildCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubview()
    }
    func initSubview() {
        sy_scrollView = self.tableView
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.right.left.equalTo(view)
            make.top.equalTo(44)
            make.height.equalTo(kScreenHeight - 44 - kNavBarHeight)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 108
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .backGray
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
}
extension SYMineChildViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == "cece" {
            return 10
        }else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? nil
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            cell?.textLabel?.textColor = .gray4Color
            cell?.textLabel?.font = .systemFont(ofSize: 15)
        }
        if type == "cece" {
          
        }else {
           
        }
        return cell!

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
