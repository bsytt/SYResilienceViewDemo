//
//  SYPageView.swift
//  SYScrollView
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import UIKit

public typealias PageViewDidSelectIndexBlock = (SYPageView, Int) -> Void
public typealias AddChildViewControllerBlock = (Int, UIViewController) -> Void

@objc public protocol SYPageViewDelegate: class {
    @objc optional func sy_scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func sy_scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func sy_scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func sy_scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func sy_scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    @objc optional func sy_scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}

public class SYPageView: UIView {
    private weak var currentViewController: UIViewController?
    private var viewControllers: [UIViewController]
    private var titles: [String]
    private var layout: SYLayout = SYLayout()
    private var sy_currentIndex: Int = 0;
    
    @objc public var didSelectIndexBlock: PageViewDidSelectIndexBlock?
    @objc public var addChildVcBlock: AddChildViewControllerBlock?
    
    /* 点击切换滚动过程动画  */
    @objc public var isClickScrollAnimation = false {
        didSet {
            pageTitleView.isClickScrollAnimation = isClickScrollAnimation
        }
    }
    
    /* pageView的scrollView左右滑动监听 */
    @objc public weak var delegate: SYPageViewDelegate?
    
    var isCustomTitleView: Bool = false
    
    var pageTitleView: SYPageTitleView!
    
    @objc public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        scrollView.contentSize = CGSize(width: self.bounds.width * CGFloat(self.titles.count), height: 0)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = layout.isShowBounces
        scrollView.isScrollEnabled = layout.isScrollEnabled
        scrollView.showsHorizontalScrollIndicator = layout.showsHorizontalScrollIndicator
        return scrollView
    }()
    
    
    @objc public init(frame: CGRect, currentViewController: UIViewController, viewControllers:[UIViewController], titles: [String], layout: SYLayout, titleView: SYPageTitleView? = nil) {
        self.currentViewController = currentViewController
        self.viewControllers = viewControllers
        self.titles = titles
        self.layout = layout
        guard viewControllers.count == titles.count else {
            fatalError("控制器数量和标题数量不一致")
        }
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        if titleView != nil {
            isCustomTitleView = true
            self.pageTitleView = titleView!
        }else {
            self.pageTitleView = setupTitleView()
        }
        self.pageTitleView.isCustomTitleView = isCustomTitleView
        setupSubViews()
    }
    
    /* 滚动到某个位置 */
    @objc public func scrollToIndex(index: Int)  {
        pageTitleView.scrollToIndex(index: index)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SYPageView {
    
    private func setupSubViews()  {
        addSubview(scrollView)
        if layout.isSinglePageView == false {
            addSubview(pageTitleView)
            sy_createViewController(0)
            setupGetPageViewScrollView(self, pageTitleView)
        }
    }
    
}

extension SYPageView {
    private func setupTitleView() -> SYPageTitleView {
        let pageTitleView = SYPageTitleView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.layout.sliderHeight), titles: titles, layout: layout)
        pageTitleView.backgroundColor = self.layout.titleViewBgColor
        return pageTitleView
    }
}

extension SYPageView {
    func setupGetPageViewScrollView(_ pageView:SYPageView, _ titleView: SYPageTitleView) {
        pageView.delegate = titleView
        titleView.mainScrollView = pageView.scrollView
        titleView.scrollIndexHandle = pageView.currentIndex
        titleView.sy_createViewControllerHandle = {[weak pageView] index in
            pageView?.sy_createViewController(index)
        }
        titleView.sy_didSelectTitleViewHandle = {[weak pageView] index in
            pageView?.didSelectIndexBlock?((pageView)!, index)
        }
    }
}

extension SYPageView {
    
    public func sy_createViewController(_ index: Int)  {
        let VC = viewControllers[index]
        guard let currentViewController = currentViewController else { return }
        if currentViewController.children.contains(VC) {
            return
        }
        var viewControllerY: CGFloat = 0.0
        layout.isSinglePageView ? viewControllerY = 0.0 : (viewControllerY = layout.sliderHeight)
        VC.view.frame = CGRect(x: scrollView.bounds.width * CGFloat(index), y: viewControllerY, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scrollView.addSubview(VC.view)
        currentViewController.addChild(VC)
        VC.automaticallyAdjustsScrollViewInsets = false
        addChildVcBlock?(index, VC)
        if let sy_scrollView = VC.sy_scrollView {
            if #available(iOS 11.0, *) {
                sy_scrollView.contentInsetAdjustmentBehavior = .never
            }
            sy_scrollView.frame.size.height = sy_scrollView.frame.size.height - viewControllerY
        }
    }
    
    public func currentIndex() -> Int {
        if scrollView.bounds.width == 0 || scrollView.bounds.height == 0 {
            return 0
        }
        let index = Int((scrollView.contentOffset.x + scrollView.bounds.width * 0.5) / scrollView.bounds.width)
        return max(0, index)
    }
    
}

extension SYPageView {
    
    private func getRGBWithColor(_ color : UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard let components = color.cgColor.components else {
            fatalError("请使用RGB方式给标题颜色赋值")
        }
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}

extension UIColor {
    
    public convenience init(r : CGFloat, g : CGFloat, b : CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
}

extension SYPageView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.sy_scrollViewDidScroll?(scrollView)
        if isCustomTitleView {
            let index = currentIndex()
            if sy_currentIndex != index {
                sy_createViewController(index)
                didSelectIndexBlock?(self, index)
                sy_currentIndex = index
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.sy_scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.sy_scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.sy_scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.sy_scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.sy_scrollViewDidEndScrollingAnimation?(scrollView)
        
    }
}


