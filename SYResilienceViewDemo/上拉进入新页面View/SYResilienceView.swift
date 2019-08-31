//
//  SYResilienceView.swift
//  DatianDigitalAgriculture
//
//  Created by bsoshy on 2019/7/30.
//  Copyright © 2019 qiaoxy. All rights reserved.
//

import UIKit
import SnapKit

protocol SYResilienceViewDelegate {
    func sy_scrollView(index:Int)
    
    func sy_tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    
    func sy_tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
}
protocol SYResilienceViewDataSource {
    func sy_numberOfSections(in tableView: UITableView) -> Int
    
    func sy_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    func sy_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    func sy_tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}
class SYResilienceView: UIView {

    let maxContentOffSet_Y:CGFloat = 95
    var dataSource : SYResilienceViewDataSource?
    var delegate : SYResilienceViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubview()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubview() {
        self.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 89
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self)
            }
        }
        self.addSubview(self.detailTableView)
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.detailTableView.estimatedRowHeight = 452
        detailTableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self.tableView.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self)
            }
        }
        // 开始监听_webView.scrollView的偏移量
        self.tableView.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: nil)
    }

    //进入详情动画
    func goToDetailAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
            self.detailTableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: self.bounds.height);
            self.tableView.frame = CGRect(x: 0, y: -self.bounds.size.height, width: kScreenWidth, height: self.bounds.size.height);
        }) { (finished) in
        }
    }
    //返回
    func backToFirstPageAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
            self.tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: self.bounds.size.height);
            self.detailTableView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.bounds.height);
            
        }) { (finished) in
        }
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.tableFooterView = UIView()
        tableView.tag = 1500
        return tableView
    }()
    lazy var detailTableView: UITableView = {
        let detail = UITableView(frame: .zero)
        detail.tag = 1501
        detail.tableFooterView = UIView()
        return detail
    }()
   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let tabV = object as! UITableView
        if (tabV == detailTableView && keyPath == "contentOffset") {
            
        }else {
//             super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    deinit {
        self.tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
}
extension SYResilienceView :UITableViewDelegate ,UITableViewDataSource,UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.sy_numberOfSections(in: tableView) ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.sy_tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (self.dataSource?.sy_tableView(tableView, cellForRowAt: indexPath))!
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.delegate?.sy_tableView(tableView, heightForFooterInSection: section) ?? 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.delegate?.sy_tableView(tableView, viewForFooterInSection: section)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dataSource?.sy_tableView(tableView, didSelectRowAt: indexPath)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        if scrollView.tag == 1500 {
            let valueNum = tableView.contentSize.height - kScreenHeight
            if offsetY - valueNum > maxContentOffSet_Y && offsetY > 0{
                //进入图文详情
                goToDetailAnimation()
                self.delegate?.sy_scrollView(index: 1)
            }
        }else{
            if (offsetY < 0 && -offsetY > maxContentOffSet_Y) {
                //返回
                backToFirstPageAnimation()
                self.delegate?.sy_scrollView(index: 0)
            }
        }
    }
}
