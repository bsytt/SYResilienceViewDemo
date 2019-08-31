//
//  SYResilienceViewController.swift
//  SYResilienceViewDemo
//
//  Created by 包曙源 on 2019/8/25.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class SYResilienceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initSubview()
    }
    func initSubview() {
        self.navigationItem.titleView = self.topView
        topView.selectIndex = 0
        
        self.view.addSubview(self.resilenceView)
        resilenceView.dataSource = self
        resilenceView.delegate = self
        resilenceView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    lazy var resilenceView: SYResilienceView = {
        let resilence = SYResilienceView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-kNavBarHeight-50))
        resilence.tableView.register(UINib(nibName: "SYResilienceCell", bundle: nil), forCellReuseIdentifier: "SYResilienceCell")
        resilence.detailTableView.register(UINib(nibName: "SYRedilienceDetailCell", bundle: nil), forCellReuseIdentifier: "SYRedilienceDetailCell")
        //        resilence.tableView.tableFooterView = self.firstBottomBtn
        return resilence
    }()
    
    lazy var topView: SYSegmentView = {
        let top = SYSegmentView(frame: CGRect(x: 0, y: 0, width: 120, height: 40),titles: ["商品","详情"], segmentViewBlock: { (index) in
            self.topView.selectIndex = index
            if index == 0 {
                self.resilenceView.backToFirstPageAnimation()
            }else {
                self.resilenceView.goToDetailAnimation()
            }
        })
        return top
    }()
}
extension SYResilienceViewController : SYResilienceViewDataSource,SYResilienceViewDelegate{
    func sy_numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1500 {
            return 3
        }
        return 2
    }
    
    func sy_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func sy_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1500 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SYResilienceCell", for: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SYRedilienceDetailCell", for: indexPath)
            return cell
        }
    }
    
    func sy_tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func sy_scrollView(index: Int) {
        topView.selectIndex = index
    }
    
    func sy_tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func sy_tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    
}

