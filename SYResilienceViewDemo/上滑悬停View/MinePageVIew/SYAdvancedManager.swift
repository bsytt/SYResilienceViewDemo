//
//  SYAdvancedManager.swift
//  SYScrollView_Example
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import UIKit

@objc public protocol SYAdvancedScrollViewDelegate: class {
    @objc optional func sy_scrollViewOffsetY(_ offsetY: CGFloat)
}

public class SYAdvancedManager: UIView {
    
    public typealias SYAdvancedDidSelectIndexHandle = (Int) -> Void
    @objc public var advancedDidSelectIndexHandle: SYAdvancedDidSelectIndexHandle?
    @objc public weak var delegate: SYAdvancedScrollViewDelegate?
    
    //设置悬停位置Y值
    @objc public var hoverY: CGFloat = 0
    
    /* 点击切换滚动过程动画 */
    @objc public var isClickScrollAnimation = false {
        didSet {
            titleView.isClickScrollAnimation = isClickScrollAnimation
        }
    }
    
    /* 代码设置滚动到第几个位置 */
    @objc public func scrollToIndex(index: Int)  {
        pageView.scrollToIndex(index: index)
    }
    
    private var kHeaderHeight: CGFloat = 0.0
    private var currentSelectIndex: Int = 0
    private var lastDiffTitleToNav:CGFloat = 0.0
    private var headerView: UIView?
    private var viewControllers: [UIViewController]
    private var titles: [String]
    private weak var currentViewController: UIViewController?
    private var pageView: SYPageView!
    private var layout: SYLayout
    var isCustomTitleView: Bool = false
    
    private var titleView: SYPageTitleView!
    
    @objc public init(frame: CGRect, viewControllers: [UIViewController], titles: [String], currentViewController:UIViewController, layout: SYLayout, titleView: SYPageTitleView? = nil, headerViewHandle handle: () -> UIView) {
        UIScrollView.initializeOnce()
        UICollectionViewFlowLayout.loadOnce()
        self.viewControllers = viewControllers
        self.titles = titles
        self.currentViewController = currentViewController
        self.layout = layout
        super.init(frame: frame)
        UICollectionViewFlowLayout.sy_sliderHeight = layout.sliderHeight
        layout.isSinglePageView = true
        if titleView != nil {
            isCustomTitleView = true
            self.titleView = titleView!
        }else {
            self.titleView = setupTitleView()
        }
        self.titleView.isCustomTitleView = isCustomTitleView
        pageView = setupPageViewConfig(currentViewController: currentViewController, layout: layout, titleView: titleView)
        setupSubViewsConfig(handle)
    }
    
    deinit {
        deallocConfig()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SYAdvancedManager {
    private func setupTitleView() -> SYPageTitleView {
        let titleView = SYPageTitleView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: layout.sliderHeight), titles: titles, layout: layout)
        return titleView
    }
}


extension SYAdvancedManager {
    //MARK: 创建PageView
    private func setupPageViewConfig(currentViewController:UIViewController, layout: SYLayout, titleView: SYPageTitleView?) -> SYPageView {
        let pageView = SYPageView(frame: self.bounds, currentViewController: currentViewController, viewControllers: viewControllers, titles: titles, layout:layout, titleView: titleView)
        if titles.count != 0 {
            pageView.sy_createViewController(0)
        }
        DispatchQueue.main.after(0.01) {
            pageView.addSubview(self.titleView)
            pageView.setupGetPageViewScrollView(pageView, self.titleView)
        }
        return pageView
    }
}


extension SYAdvancedManager {
    
    private func setupSubViewsConfig(_ handle: () -> UIView) {
        let headerView = handle()
        kHeaderHeight = headerView.bounds.height
        self.headerView = headerView
        lastDiffTitleToNav = kHeaderHeight
        setupSubViews()
        addSubview(headerView)
    }
    
    private func setupSubViews() {
        titleView.frame.origin.y = kHeaderHeight
        backgroundColor = UIColor.white
        addSubview(pageView)
        setupPageViewDidSelectItem()
        setupFirstAddChildViewController()
        guard let viewController = viewControllers.first else { return }
        self.contentScrollViewScrollConfig(viewController)
        scrollInsets(viewController, kHeaderHeight+layout.sliderHeight)
    }
    
}


extension SYAdvancedManager {
    
    //设置ScrollView的contentInset
    private func scrollInsets(_ currentVC: UIViewController ,_ up: CGFloat) {
        currentVC.sy_scrollView?.contentInset = UIEdgeInsets(top: up, left: 0, bottom: 0, right: 0)
        currentVC.sy_scrollView?.scrollIndicatorInsets = UIEdgeInsets(top: up, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: 首次创建pageView的ChildVC回调
    private func setupFirstAddChildViewController() {
        
        //首次创建pageView的ChildVC回调
        pageView.addChildVcBlock = {[weak self] in
            guard let `self` = self else { return }
            let currentVC = self.viewControllers[$0]
            
            //设置ScrollView的contentInset
            self.scrollInsets(currentVC, self.kHeaderHeight+self.layout.sliderHeight)
            //            self.scrollInsets(currentVC, 100)
            
            //初始化滚动回调 首次加载并不会执行内部方法
            self.contentScrollViewScrollConfig($1)
            
            //注意：节流---否则此方法无效。。
            self.setupFirstAddChildScrollView()
        }
    }
    
    func sy_adjustScrollViewContentSizeHeight(sy_scrollView: UIScrollView?) {
        guard let sy_scrollView = sy_scrollView else { return }
        //当前ScrollView的contentSize的高 = 当前ScrollView的的高 避免自动掉落
        let sliderH = self.layout.sliderHeight
        if sy_scrollView.contentSize.height < sy_scrollView.bounds.height - sliderH {
            sy_scrollView.contentSize.height = sy_scrollView.bounds.height - sliderH
        }
    }
    
    //MARK: 首次创建pageView的ChildVC回调 自适应调节
    private func setupFirstAddChildScrollView() {
        
        //注意：节流---否则此方法无效。。
        DispatchQueue.main.after(0.01, execute: {
            
            let currentVC = self.viewControllers[self.currentSelectIndex]
            
            guard let sy_scrollView = currentVC.sy_scrollView else { return }
            
            self.sy_adjustScrollViewContentSizeHeight(sy_scrollView: sy_scrollView)
            
            sy_scrollView.contentOffset.y = self.distanceBottomOffset()
            
            /*
             //当前ScrollView的contentSize的高
             let contentSizeHeight = sy_scrollView.contentSize.height
             
             //当前ScrollView的的高
             let boundsHeight = sy_scrollView.bounds.height - self.layout.sliderHeight
             
             //此处说明内容的高度小于bounds 应该让pageTitleView自动回滚到初始位置
             if contentSizeHeight <  boundsHeight {
             
             //为自动掉落加一个动画
             UIView.animate(withDuration: 0.12, animations: {
             //初始的偏移量 即初始的contentInset的值
             let offsetPoint = CGPoint(x: 0, y: -self.kHeaderHeight-self.layout.sliderHeight)
             
             //注意：此处调用此方法并不会执行scrollViewDidScroll:原因未可知
             sy_scrollView.setContentOffset(offsetPoint, animated: true)
             
             //在这里手动执行一下scrollViewDidScroll:事件
             self.setupSY_scrollViewDidScroll(scrollView: sy_scrollView, currentVC: currentVC)
             })
             
             
             }else {
             //首次初始化，通过改变当前ScrollView的偏移量，来确保ScrollView正好在pageTitleView下方
             sy_scrollView.contentOffset.y = self.distanceBottomOffset()
             }
             */
        })
        
    }
    
    //MARK: 当前的scrollView滚动的代理方法开始
    private func contentScrollViewScrollConfig(_ viewController: UIViewController) {
        
        viewController.sy_scrollView?.scrollHandle = {[weak self] scrollView in
            
            guard let `self` = self else { return }
            
            let currentVC = self.viewControllers[self.currentSelectIndex]
            
            guard currentVC.sy_scrollView == scrollView else { return }
            
            self.sy_adjustScrollViewContentSizeHeight(sy_scrollView: currentVC.sy_scrollView)
            
            self.setupSY_scrollViewDidScroll(scrollView: scrollView, currentVC: currentVC)
        }
    }
    
    //MARK: 当前控制器的滑动方法事件处理 1
    private func setupSY_scrollViewDidScroll(scrollView: UIScrollView, currentVC: UIViewController)  {
        
        //pageTitleView距离屏幕顶部到pageTitleView最底部的距离
        let distanceBottomOffset = self.distanceBottomOffset()
        
        //当前控制器上一次的偏移量
        let sy_upOffsetString = currentVC.sy_upOffset ?? String(describing: distanceBottomOffset)
        
        //先转化为Double(String转CGFloat步骤：String -> Double -> CGFloat)
        let sy_upOffsetDouble = Double(sy_upOffsetString) ?? Double(distanceBottomOffset)
        
        //再转化为CGFloat
        let sy_upOffset = CGFloat(sy_upOffsetDouble)
        
        //计算上一次偏移和当前偏移量y的差值
        let absOffset = scrollView.contentOffset.y - sy_upOffset
        
        //处理滚动
        self.contentScrollViewDidScroll(scrollView, absOffset)
        
        //记录上一次的偏移量
        currentVC.sy_upOffset = String(describing: scrollView.contentOffset.y)
    }
    
    
    //MARK: 当前控制器的滑动方法事件处理 2
    private func contentScrollViewDidScroll(_ contentScrollView: UIScrollView, _ absOffset: CGFloat)  {
        
        //获取当前控制器
        let currentVc = viewControllers[currentSelectIndex]
        
        //外部监听当前ScrollView的偏移量
        self.delegate?.sy_scrollViewOffsetY?((currentVc.sy_scrollView?.contentOffset.y ?? kHeaderHeight) + self.kHeaderHeight + layout.sliderHeight)
        
        //获取偏移量
        let offsetY = contentScrollView.contentOffset.y
        
        //获取当前pageTitleView的Y值
        var pageTitleViewY = titleView.frame.origin.y
        
        //pageTitleView从初始位置上升的距离
        let titleViewBottomDistance = offsetY + kHeaderHeight + layout.sliderHeight
        
        let headerViewOffset = titleViewBottomDistance + pageTitleViewY
        
        if absOffset > 0 && titleViewBottomDistance > 0 {//向上滑动
            if headerViewOffset >= kHeaderHeight {
                pageTitleViewY += -absOffset
                if pageTitleViewY <= hoverY {
                    pageTitleViewY = hoverY
                }
            }
        }else{//向下滑动
            if headerViewOffset < kHeaderHeight {
                pageTitleViewY = -titleViewBottomDistance + kHeaderHeight
                if pageTitleViewY >= kHeaderHeight {
                    pageTitleViewY = kHeaderHeight
                }
            }
        }
        
        titleView.frame.origin.y = pageTitleViewY
        headerView?.frame.origin.y = pageTitleViewY - kHeaderHeight
        let lastDiffTitleToNavOffset = pageTitleViewY - lastDiffTitleToNav
        lastDiffTitleToNav = pageTitleViewY
        //使其他控制器跟随改变
        for subVC in viewControllers {
            sy_adjustScrollViewContentSizeHeight(sy_scrollView: subVC.sy_scrollView)
            guard subVC != currentVc else { continue }
            guard let vcSY_scrollView = subVC.sy_scrollView else { continue }
            vcSY_scrollView.contentOffset.y += (-lastDiffTitleToNavOffset)
            subVC.sy_upOffset = String(describing: vcSY_scrollView.contentOffset.y)
        }
    }
    
    private func distanceBottomOffset() -> CGFloat {
        return -(titleView.frame.origin.y + layout.sliderHeight)
    }
}


extension SYAdvancedManager {
    
    //MARK: pageView选中事件
    private func setupPageViewDidSelectItem()  {
        
        pageView.didSelectIndexBlock = {[weak self] in
            
            guard let `self` = self else { return }
            
            self.setupUpViewControllerEndRefreshing()
            
            self.currentSelectIndex = $1
            
            self.advancedDidSelectIndexHandle?($1)
            
            self.setupContentSizeBoundsHeightAdjust()
            
        }
    }
    
    //MARK: 内容的高度小于bounds 应该让pageTitleView自动回滚到初始位置
    private func setupContentSizeBoundsHeightAdjust()  {
        
        DispatchQueue.main.after(0.01, execute: {
            
            let currentVC = self.viewControllers[self.currentSelectIndex]
            
            guard let sy_scrollView = currentVC.sy_scrollView else { return }
            
            self.sy_adjustScrollViewContentSizeHeight(sy_scrollView: sy_scrollView)
            
            //当前ScrollView的contentSize的高
            let contentSizeHeight = sy_scrollView.contentSize.height
            
            //当前ScrollView的的高
            let boundsHeight = sy_scrollView.bounds.height - self.layout.sliderHeight
            
            //此处说明内容的高度小于bounds 应该让pageTitleView自动回滚到初始位置
            //这里不用再进行其他操作，因为会调用ScrollViewDidScroll:
            if contentSizeHeight <  boundsHeight {
                let offsetPoint = CGPoint(x: 0, y: -self.kHeaderHeight-self.layout.sliderHeight)
                sy_scrollView.setContentOffset(offsetPoint, animated: true)
            }
        })
    }
    
    //MARK: 处理下拉刷新的过程中切换导致的问题
    private func setupUpViewControllerEndRefreshing() {
        //如果正在下拉，则在切换之前把上一个的ScrollView的偏移量设置为初始位置
        DispatchQueue.main.after(0.01) {
            let upVC = self.viewControllers[self.currentSelectIndex]
            guard let sy_scrollView = upVC.sy_scrollView else { return }
            //判断是下拉
            if sy_scrollView.contentOffset.y < (-self.kHeaderHeight-self.layout.sliderHeight) {
                let offsetPoint = CGPoint(x: 0, y: -self.kHeaderHeight-self.layout.sliderHeight)
                sy_scrollView.setContentOffset(offsetPoint, animated: true)
            }
        }
    }
    
}

extension SYAdvancedManager {
    private func deallocConfig() {
        for viewController in viewControllers {
            viewController.sy_scrollView?.delegate = nil
        }
    }
}
