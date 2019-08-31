//
//  SYMineFirstStyleViewController.swift
//  SYResilienceViewDemo
//
//  Created by 包曙源 on 2019/8/25.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class SYMineFirstStyleViewController: UIViewController {

    let headHeight:CGFloat = 200

    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .white
        initSubview()
    }
    func initSubview() {
        self.navigationController?.delegate = self

        self.view.addSubview(self.tableView)
        tableView.register(UINib(nibName: "SYResilienceCell", bundle: nil), forCellReuseIdentifier: "SYResilienceCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.view)
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: headHeight, left: 0, bottom: 0, right: 0)
        self.tableView.addSubview(self.headView)
        headView.clickBlock = {[weak self] in

        }
        
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    //头部个人信息视图
    lazy var headView: SYMainMineHeadView = {
        let head = SYMainMineHeadView(frame: CGRect(x: 0, y: -headHeight, width: kScreenWidth, height: headHeight))
        return head
    }()
}
extension SYMineFirstStyleViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYResilienceCell", for: indexPath)
        return cell
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if(-offsetY > headHeight){
            var frame = headView.frame
            frame.origin.y = offsetY
            frame.size.height = -offsetY
            headView.frame = frame
        }
    }
}
extension SYMineFirstStyleViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 判断要显示的控制器是否是自己
        let isShowHomePage = viewController.isKind(of: self.classForCoder)
        self.navigationController?.setNavigationBarHidden(isShowHomePage, animated: true)
    }
}
