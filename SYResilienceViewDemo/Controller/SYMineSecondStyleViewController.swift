//
//  SYMineSecondStyleViewController.swift
//  SYResilienceViewDemo
//
//  Created by 包曙源 on 2019/8/25.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class SYMineSecondStyleViewController: UIViewController {

    private let headerHeight: CGFloat = 248.0
    var navagitionImage : UIImage?
    var offsetY:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initSubview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if offsetY >= headerHeight - kNavBarHeight {
            DispatchQueue.main.after(time: DispatchTime.now() + 0.1) {
                self.navigationController?.navigationBar.setBackgroundImage(self.navagitionImage, for: .any, barMetrics: .default)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
    }
    func initSubview() {
        self.navigationController?.navigationBar.shadowImage=UIImage()
//        self.automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top_fanhui_0"), style: .plain, target: self, action: #selector(backBarItemClick))
        self.navigationController?.navigationBar.tintColor = .white
        let originalImage =  UIImage(named: "onepiece_kiudai")
        navagitionImage = originalImage?.gaosiBlur(blur: 1)
        view.addSubview(simpleManager)
        simpleManagerConfig()
    }
    private lazy var titles: [String] = {
        return ["cece","hahah"]
    }()
    
    //初始化子视图控制器
    private lazy var viewControllers: [UIViewController] = {
        var vcs = [UIViewController]()
        for text in titles {
            let vc = SYMineChildViewController()
            vc.type = text
            vcs.append(vc)
        }
        return vcs
    }()
    private lazy var headMsgBackView: SYMineHeadView = {
        let headerView = SYMineHeadView(frame: CGRect(x: 0, y: 125, width: view.bounds.width, height: headerHeight - 125))
        headerView.concernBlock = {[weak self] in
            print("关注")
        }
        return headerView
    }()
    private lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        return headerView
    }()
    private lazy var headerImageView: UIImageView = {
        let headerImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerView.bounds.height-125))
        headerImageView.isUserInteractionEnabled = true
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        let originalImage =  UIImage(named: "onepiece_kiudai")
        headerImageView.image = originalImage?.gaosiBlur(blur: 1)
        headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:))))
        return headerImageView
    }()
    private lazy var layout: SYLayout = {
        let layout = SYLayout()
        return layout
    }()
    private lazy var simpleManager: SYSimpleManager = {
        let H: CGFloat = isIPhoneX ? (view.bounds.height - 34) : view.bounds.height
        let simpleManager = SYSimpleManager(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: H), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout)
        simpleManager.delegate = self
        /* 设置悬停位置 */
        simpleManager.hoverY = kNavBarHeight
        return simpleManager
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //返回
    @objc func backBarItemClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
extension SYMineSecondStyleViewController {
    private func simpleManagerConfig() {
        //MARK: headerView设置
        simpleManager.configHeaderView {[weak self] in
            self?.headerView.addSubview(self!.headerImageView)
            self?.headerView.addSubview(self!.headMsgBackView)
            return self?.headerView
        }
        //MARK: pageView点击事件
        simpleManager.didSelectIndexHandle { (index) in
            print("点击了 \(index)")
        }
    }
    
    @objc private func tapLabel(_ gesture: UITapGestureRecognizer)  {
        print("tapHead")
    }
}
extension SYMineSecondStyleViewController: SYSimpleScrollViewDelegate {
    //MARK: 滚动代理方法
    func sy_scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var headerImageViewY: CGFloat = offsetY
        var headerImageViewH: CGFloat = 125 - offsetY
        if offsetY > 0.0 {
            headerImageViewY = 0
            headerImageViewH = 125
            if offsetY >= headerHeight - kNavBarHeight {
                self.navigationController?.navigationBar.setBackgroundImage(navagitionImage, for: .any, barMetrics: .default)
            }else {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            }
        }
        self.offsetY = offsetY
        headerImageView.frame.origin.y = headerImageViewY
        headerImageView.frame.size.height = headerImageViewH
    }
    //MARK: 控制器刷新事件代理方法
    func sy_refreshScrollView(_ scrollView: UIScrollView, _ index: Int) {
        //        scrollView.mj_header = MJRefreshNormalHeader {[weak scrollView] in
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        //                scrollView?.mj_header.endRefreshing()
        //            })
        //        }
    }
}
