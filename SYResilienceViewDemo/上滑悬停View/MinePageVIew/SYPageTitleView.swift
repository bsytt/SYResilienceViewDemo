//
//  SYPageTitleView.swift
//  SYScrollView_Example
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import UIKit

typealias scrollIndexHandle = () -> Int
public typealias SYCreateViewControllerHandle = (Int) -> Void
public typealias SYDidSelectTitleViewHandle = (Int) -> Void

@objc public class SYPageTitleView: UIView {
    
    /*  自定义titleView选择性重写以下方法 */
    
    /**
     * layout中属性 isCustomTitleView 必须需要设置为 true
     * layout中属性 isCustomTitleViewAndCreateSubController 根据实际情况是否需要设置为true
     */
    @objc public var mainScrollView: UIScrollView?
    @objc public func sy_contentScrollViewDidScroll(_ scrollView: UIScrollView) { }
    @objc public func sy_contentScrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    @objc public func sy_contentScrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}
    @objc public func sy_contentScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    @objc public func sy_contentScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    @objc public func sy_contentScrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
    
    /*  自定义titleView选择性重写以上方法 */
    
    private var titles: [String] = [String]()
    private var layout: SYLayout = SYLayout()
    private var sy_textWidths: [CGFloat] = []
    private var sy_lineWidths: [CGFloat] = []
    private var sy_buttons: [UIButton] = []
    private var sy_currentIndex: Int = 0
    private var isClick: Bool = false
    private var sy_startOffsetX: CGFloat = 0.0
    private var sy_isClickScrollAnimation = false
    var isClickScrollAnimation = false
    private var isFirstLoad: Bool = true
    var scrollIndexHandle: scrollIndexHandle?
    var sy_createViewControllerHandle: SYCreateViewControllerHandle?
    var sy_didSelectTitleViewHandle: SYDidSelectTitleViewHandle?
    var isCustomTitleView: Bool = false {
        didSet {
            if isCustomTitleView == false {
                setupSubViews()
            }
        }
    }
    weak var delegate: SYPageViewDelegate?
    
    private lazy var sy_titleRGBlColor: (r : CGFloat, g : CGFloat, b : CGFloat) = getRGBWithColor(layout.titleColor ?? NORMAL_BASE_COLOR)
    private lazy var sy_selectTitleRGBlColor: (r : CGFloat, g : CGFloat, b : CGFloat) = getRGBWithColor(layout.titleSelectColor ?? SELECT_BASE_COLOR)
    
    private lazy var sliderScrollView: UIScrollView = {
        let sliderScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        sliderScrollView.showsHorizontalScrollIndicator = false
        sliderScrollView.bounces = false
        return sliderScrollView
    }()
    
    private lazy var pageBottomLineView: UIView = {
        let pageBottomLineView = UIView(frame: CGRect(x: 0, y: bounds.height - layout.pageBottomLineHeight, width: bounds.width, height: layout.pageBottomLineHeight))
        pageBottomLineView.backgroundColor = layout.pageBottomLineColor
        return pageBottomLineView
    }()
    
    private lazy var sliderLineView: UIView = {
        let sliderLineView = UIView(frame: CGRect(x: layout.lrMargin, y: bounds.height - layout.bottomLineHeight - layout.pageBottomLineHeight, width: 0, height: layout.bottomLineHeight))
        sliderLineView.backgroundColor = layout.bottomLineColor
        return sliderLineView
    }()
    
    @objc public init(frame: CGRect, titles: [String], layout: SYLayout) {
        self.titles = titles
        self.layout = layout
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            sliderScrollView.contentInsetAdjustmentBehavior = .never
        }
        backgroundColor = layout.titleViewBgColor
    }
    
    /* 滚动到某个位置 */
    @objc public func scrollToIndex(index: Int)  {
        var index = index
        sy_setupScrollToIndex(&index)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SYPageTitleView {
    func setupSubViews() {
        addSubview(sliderScrollView)
        sliderScrollView.addSubview(sliderLineView)
        addSubview(pageBottomLineView)
        setupButtonsLayout()
    }
}


extension SYPageTitleView {
    
    private func setupButtonsLayout() {
        
        if titles.count == 0 { return }
        
        // 将所有的宽度计算出来放入数组
        for (_, text) in titles.enumerated() {
            if layout.isAverage {
                let textAverageW = (bounds.width - layout.lrMargin * 2.0 - layout.titleMargin * CGFloat(titles.count - 1)) / CGFloat(titles.count)
                sy_textWidths.append(textAverageW)
                sy_lineWidths.append(textAverageW)
            }else {
                if text.count == 0 {
                    sy_textWidths.append(60)
                    sy_lineWidths.append(60)
                    continue
                }
                let textW = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 8), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : layout.titleFont ?? UIFont.systemFont(ofSize: 16)], context: nil).size.width
                sy_textWidths.append(textW)
                sy_lineWidths.append(textW)
            }
        }
        
        
        
        // 将所有的宽度计算出来放入数组
        for text in titles {
            if layout.isAverage {
                let textAverageW = (bounds.width - layout.lrMargin * 2.0 - layout.titleMargin * CGFloat(titles.count - 1)) / CGFloat(titles.count)
                sy_textWidths.append(textAverageW)
            }else {
                if text.count == 0 {
                    sy_textWidths.append(60)
                    sy_lineWidths.append(60)
                    continue
                }
            }
            let textW = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 8), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : layout.titleFont ?? UIFont.systemFont(ofSize: 16)], context: nil).size.width
            if !layout.isAverage {
                sy_textWidths.append(textW)
            }
            sy_lineWidths.append(textW)
        }
        
        // 按钮布局
        var upX: CGFloat = layout.lrMargin
        let subH = bounds.height - layout.bottomLineHeight
        for index in 0..<titles.count {
            var subW = sy_textWidths[index]
            if titles.count <= 4 {
                subW = (kScreenWidth-(CGFloat(titles.count)+1)*22)/CGFloat(titles.count)
            }
            let buttonReact = CGRect(x: upX, y: 0, width: subW, height: subH)
            let button = subButton(frame: buttonReact, flag: index, title: titles[index], parentView: sliderScrollView)
            let color = (index == 0 ? layout.titleSelectColor : layout.titleColor)
            button.setTitleColor(color, for: .normal)
            upX = button.frame.origin.x + subW + layout.titleMargin
            sy_buttons.append(button)
            
        }
        
        let firstButton = sy_buttons[0]
        let firstLineWidth = sy_lineWidths[0]
        let firstTextWidth = sy_textWidths[0]
        
        if layout.isNeedScale {
            firstButton.transform = CGAffineTransform(scaleX: layout.scale , y: layout.scale)
        }
        
        // lineView的宽度为第一个的宽度
        if layout.sliderWidth == sy_sliderDefaultWidth {
            if layout.isAverage {
                sliderLineView.frame.size.width = firstLineWidth
                sliderLineView.center.x = firstButton.center.x

            }else {
                sliderLineView.frame.size.width = firstTextWidth
                sliderLineView.center.x = firstButton.center.x
            }
        }else {
            sliderLineView.frame.size.width = layout.sliderWidth
            sliderLineView.center.x = firstButton.center.x

        }
        
        if layout.bottomLineCornerRadius != 0.0 {
            sliderLineView.layer.cornerRadius = layout.bottomLineCornerRadius
            sliderLineView.layer.masksToBounds = true
            sliderLineView.clipsToBounds = true
        }
        
        if layout.isAverage {
            sliderScrollView.contentSize = CGSize(width: bounds.width, height: 0)
            return
        }
        
        // 计算sliderScrollView的contentSize
        let sliderContenSizeW = upX - layout.titleMargin + layout.lrMargin
        
        if sliderContenSizeW < bounds.width {
            sliderScrollView.frame.size.width = sliderContenSizeW
        }
        
        //最后多加了一个 layout.titleMargin， 这里要减去
        sliderScrollView.contentSize = CGSize(width: sliderContenSizeW, height: 0)
        
    }
    @objc private func titleSelectIndex(_ btn: UIButton)  {
        
        setupTitleSelectIndex(btn.tag)
        
    }
    
    private func setupTitleSelectIndex(_ btnSelectIndex: Int) {
        guard let scrollView = mainScrollView else { return }
        if sy_currentIndex == btnSelectIndex || scrollView.isDragging || scrollView.isDecelerating {
            return
        }
        let totalW = bounds.width
        isClick = true
        sy_isClickScrollAnimation = true
        scrollView.setContentOffset(CGPoint(x: totalW * CGFloat(btnSelectIndex), y: 0), animated: isClickScrollAnimation)
        if isClickScrollAnimation {
            return
        }
        let nextButton = sy_buttons[btnSelectIndex]
        let w = sy_lineWidths[btnSelectIndex]
        if layout.sliderWidth == sy_sliderDefaultWidth {
            if layout.isAverage {
                let adjustX = (nextButton.frame.size.width - sy_lineWidths[btnSelectIndex]) * 0.5
                sliderLineView.frame.origin.x = nextButton.frame.origin.x + adjustX
                sliderLineView.frame.size.width = sy_lineWidths[btnSelectIndex]
            }else {
                sliderLineView.frame.size.width = w
                sliderLineView.center.x = nextButton.center.x
            }
        }else {
            setupSliderLineViewWidth(currentButton: nextButton)
        }
        sy_currentIndex = btnSelectIndex
    }
    
}

//MARK: 处理刚进入滚动到第几个位置
extension SYPageTitleView {
    
    private func sy_setupScrollToIndex(_ index:inout Int) {
        if index >= titles.count {
            print("超过最大数量限制, 请正确设置值, 默认这里取第一个")
            index = 0
        }
        
        if isClickScrollAnimation {
            
            let nextButton = sy_buttons[index]
            
            if layout.sliderWidth == sy_sliderDefaultWidth {
                
                if layout.isAverage {
                    let adjustX = (nextButton.frame.size.width - sy_lineWidths[index]) * 0.5
                    sliderLineView.frame.origin.x = nextButton.frame.origin.x + adjustX
                    sliderLineView.frame.size.width = sy_lineWidths[index]
                }else {
                    sliderLineView.frame.origin.x = nextButton.frame.origin.x
                    sliderLineView.frame.size.width = nextButton.frame.width
                }
                
            }else {
                if isFirstLoad {
                    setupSliderLineViewWidth(currentButton: sy_buttons[index])
                    isFirstLoad = false
                }
            }
        }
        
        setupTitleSelectIndex(index)
    }
    
}

extension SYPageTitleView: SYPageViewDelegate {
    
    private func scrollViewDidScrollOffsetX(_ offsetX: CGFloat)  {
        
        _ = setupLineViewX(offsetX: offsetX)
        
        let index = currentIndex()
        
        if sy_currentIndex != index {
            
            //如果开启滚动动画
            if isClickScrollAnimation {
                //如果不是点击事件继续在这个地方设置偏移
                if !sy_isClickScrollAnimation {
                    setupSlierScrollToCenter(offsetX: offsetX, index: index)
                }
            }else {
                //设置滚动的位置
                setupSlierScrollToCenter(offsetX: offsetX, index: index)
            }
            
            // 如果是点击的话
            if isClick {
                
                let upButton = sy_buttons[sy_currentIndex]
                
                let currentButton = sy_buttons[index]
                
                if layout.isNeedScale {
                    UIView.animate(withDuration: 0.2, animations: {
                        currentButton.transform = CGAffineTransform(scaleX: self.layout.scale , y: self.layout.scale)
                        upButton.transform = CGAffineTransform(scaleX: 1.0 , y: 1.0 )
                    })
                }
                
                setupButtonStatusAnimation(upButton: upButton, currentButton: currentButton)
                
            }
            
            if layout.isColorAnimation == false {
                let upButton = sy_buttons[sy_currentIndex]
                let currentButton = sy_buttons[index]
                setupButtonStatusAnimation(upButton: upButton, currentButton: currentButton)
            }
            
            //如果开启滚动动画
            if isClickScrollAnimation {
                //如果不是点击事件继续在这个地方设置偏移
                if !sy_isClickScrollAnimation {
                    sy_createViewControllerHandle?(index)
                    sy_didSelectTitleViewHandle?(index)
                }
            }else {
                //默认的设置
                sy_createViewControllerHandle?(index)
                sy_didSelectTitleViewHandle?(index)
            }
            sy_currentIndex = index
        }
        isClick = false
        
    }
    
    //MARK: 让title的ScrollView滚动到中心点位置
    private func setupSlierScrollToCenter(offsetX: CGFloat, index: Int)  {
        let currentButton = sy_buttons[index]
        let btnCenterX = currentButton.center.x
        var scrollX = btnCenterX - sliderScrollView.bounds.width * 0.5
        if scrollX < 0 {
            scrollX = 0
        }
        if scrollX > sliderScrollView.contentSize.width - sliderScrollView.bounds.width {
            scrollX = sliderScrollView.contentSize.width - sliderScrollView.bounds.width
        }
        sliderScrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
    }
    
    private func setupButtonStatusAnimation(upButton: UIButton, currentButton: UIButton)  {
        upButton.setTitleColor(layout.titleColor, for: .normal)
        currentButton.setTitleColor(layout.titleSelectColor, for: .normal)
    }
    
    private func currentIndex() -> Int {
        return scrollIndexHandle?() ?? 0
    }
    
    
    
    private func setupIsClickScrollAnimation(index: Int) {
        if !isClickScrollAnimation {
            return
        }
        for button in sy_buttons {
            if button.tag == index {
                if layout.isNeedScale {
                    button.transform = CGAffineTransform(scaleX: layout.scale , y: layout.scale)
                }
                button.setTitleColor(self.layout.titleSelectColor, for: .normal)
            }else {
                if layout.isNeedScale {
                    button.transform = CGAffineTransform(scaleX: 1.0 , y: 1.0)
                }
                button.setTitleColor(self.layout.titleColor, for: .normal)
            }
        }
        sy_isClickScrollAnimation = false
    }
}

extension SYPageTitleView {
    
    //MARK: 设置线的移动
    private func setupLineViewX(offsetX: CGFloat) -> Bool {
        if isClick {
            return false
        }
        //目的是改变它的值，让制滑动第一个和最后一个的时候（-0.5），导致数组下标越界
        var offsetX = offsetX
        let scrollW = bounds.width
        let scrollContenSizeW: CGFloat = bounds.width * CGFloat(titles.count)
        // 目的是滑动到最后一个的时候 不让其再往后滑动
        if offsetX + scrollW >= scrollContenSizeW {
            if layout.sliderWidth == sy_sliderDefaultWidth {
                let adjustX = (sy_textWidths.last! - sy_lineWidths.last!) * 0.5
                sliderLineView.frame.origin.x = layout.lrMargin + adjustX
            }else {
                setupSliderLineViewWidth(currentButton: sy_buttons.last!)
            }
            offsetX = scrollContenSizeW - scrollW - 0.5
        }
        // 目的是滑动到第一个的时候 不让其再往前滑动
        if offsetX <= 0 {
            if layout.sliderWidth == sy_sliderDefaultWidth {
                let adjustX = (sy_textWidths[0] - sy_lineWidths[0]) * 0.5
                sliderLineView.frame.origin.x = layout.lrMargin + adjustX
            }else {
                sliderLineView.frame.origin.x = ((sy_textWidths[0] + layout.lrMargin * 2) - layout.sliderWidth) * 0.5
            }
            offsetX = 0.5
        }
        var nextIndex = Int(offsetX / scrollW)
        var sourceIndex = Int(offsetX / scrollW)
        //向下取整 目的是减去整数位，只保留小数部分
        var progress = (offsetX / scrollW) - floor(offsetX / scrollW)
        if offsetX > sy_startOffsetX { // 向左滑动
            //向左滑动 下个位置比源位置下标 多1
            nextIndex = nextIndex + 1
        }else { // 向右滑动
            //向右滑动 由于源向下取整的缘故 必须补1 nextIndex则恰巧是原始位置
            sourceIndex = sourceIndex + 1
            progress = 1 - progress
        }
        let nextButton = sy_buttons[nextIndex]
        let currentButton = sy_buttons[sourceIndex]
        let nextw = sy_lineWidths[nextIndex]
        let currentw = sy_lineWidths[sourceIndex]
        if layout.isColorAnimation {
            let colorDelta = (sy_selectTitleRGBlColor.0 - sy_titleRGBlColor.0, sy_selectTitleRGBlColor.1 - sy_titleRGBlColor.1, sy_selectTitleRGBlColor.2 - sy_titleRGBlColor.2)
            let nextColor = UIColor(r: sy_titleRGBlColor.0 + colorDelta.0 * progress, g: sy_titleRGBlColor.1 + colorDelta.1 * progress, b: sy_titleRGBlColor.2 + colorDelta.2 * progress)
            let currentColor = UIColor(r: sy_selectTitleRGBlColor.0 - colorDelta.0 * progress, g: sy_selectTitleRGBlColor.1 - colorDelta.1 * progress, b: sy_selectTitleRGBlColor.2 - colorDelta.2 * progress)
            currentButton.setTitleColor(currentColor, for: .normal)
            nextButton.setTitleColor(nextColor, for: .normal)
        }
        if layout.isNeedScale {
            let scaleDelta = (layout.scale - 1.0) * progress
            currentButton.transform = CGAffineTransform(scaleX: layout.scale - scaleDelta, y: layout.scale - scaleDelta)
            nextButton.transform = CGAffineTransform(scaleX: 1.0 + scaleDelta, y: 1.0 + scaleDelta)
        }
        // 判断是否是自定义Slider的宽度（这里指没有自定义）
        if layout.sliderWidth == sy_sliderDefaultWidth {
            
            if layout.isAverage {
                /*
                 * 原理：（按钮的宽度 - 线的宽度）/ 2 = 线的X便宜量
                 * 如果是不是平均分配 按钮的宽度 = 线的宽度
                 */
                // 计算宽度的该变量
                let moveW = sy_lineWidths[nextIndex] - sy_lineWidths[sourceIndex]
                
                // （按钮的宽度 - 线的宽度）/ 2
                let nextButtonAdjustX = (nextButton.frame.size.width - sy_lineWidths[nextIndex]) * 0.5
                
                // （按钮的宽度 - 线的宽度）/ 2
                let currentButtonAdjustX = (currentButton.frame.size.width - sy_lineWidths[sourceIndex]) * 0.5
                
                // x的该变量
                let moveX = (nextButton.frame.origin.x + nextButtonAdjustX) - (currentButton.frame.origin.x + currentButtonAdjustX)
                
                self.sliderLineView.frame.size.width = sy_lineWidths[sourceIndex] + moveW * progress
                
                self.sliderLineView.frame.origin.x = currentButton.frame.origin.x + moveX * progress + currentButtonAdjustX
                
            }else {
//                // 计算宽度的该变量
                let moveW = nextw - currentw
                // 计算X的该变量
                let moveX = nextButton.center.x - currentButton.center.x
                sliderLineView.frame.size.width = moveW

                self.sliderLineView.frame.size.width = currentw + moveW * progress
                self.sliderLineView.center.x = currentButton.center.x + moveX * progress
            }
            
        }else {
            
            
            /*
             * 原理：按钮的最左边X（因为有lrMargin，这里必须减掉） 以及 按钮的相对右边X（注意不是最右边，因为每个按钮的X都有一个lrMargin， 所以相对右边则有两个才能保证按钮的位置，这个和titleMargin无关）
             */
            let maxNextLeft = nextButton.frame.origin.x - layout.lrMargin
            let maxNextRight = maxNextLeft + layout.lrMargin * 2.0 + nextButton.frame.size.width
            let originNextX = (maxNextRight - maxNextLeft - layout.sliderWidth) * 0.5 + maxNextLeft
            
            let maxLeft = currentButton.frame.origin.x - layout.lrMargin
            let maxRight = maxLeft + layout.lrMargin * 2.0 + currentButton.frame.size.width
            let originX = (maxRight - maxLeft - layout.sliderWidth) * 0.5 + maxLeft
            
            let moveX = originNextX - originX
            
            self.sliderLineView.frame.origin.x = originX + moveX * progress
            
            sliderLineView.frame.size.width = layout.sliderWidth
        }
        
        return false
    }
    
    // currentButton将要滚动到的按钮
    private func setupSliderLineViewWidth(currentButton: UIButton)  {
        let maxLeft = currentButton.frame.origin.x - layout.lrMargin
        let maxRight = maxLeft + layout.lrMargin * 2 + currentButton.frame.size.width
        let originX = (maxRight - maxLeft - layout.sliderWidth) * 0.5  + maxLeft
        sliderLineView.frame.origin.x = originX
        sliderLineView.frame.size.width = layout.sliderWidth
    }
}

extension SYPageTitleView {
    
    public func sy_scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            sy_contentScrollViewDidScroll(scrollView)
            return
        }
        scrollViewDidScrollOffsetX(scrollView.contentOffset.x)
    }
    
    public func sy_scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.sy_scrollViewWillBeginDragging?(scrollView)
        if isCustomTitleView {
            sy_contentScrollViewWillBeginDragging(scrollView)
            return
        }
        sy_startOffsetX = scrollView.contentOffset.x
    }
    
    public func sy_scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            sy_contentScrollViewWillBeginDecelerating(scrollView)
            return
        }
    }
    
    public func sy_scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            sy_contentScrollViewDidEndDecelerating(scrollView)
            return
        }
    }
    
    public func sy_scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.sy_scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        if isCustomTitleView {
            sy_contentScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
            return
        }
    }
    
    public func sy_scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            sy_contentScrollViewDidEndScrollingAnimation(scrollView)
            return
        }
        if sy_isClickScrollAnimation {
            let index = currentIndex()
            sy_createViewControllerHandle?(index)
            setupSlierScrollToCenter(offsetX: scrollView.contentOffset.x, index: index)
            setupIsClickScrollAnimation(index: index)
            sy_didSelectTitleViewHandle?(index)
        }
    }
}

extension SYPageTitleView {
    
    private func getRGBWithColor(_ color : UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard let components = color.cgColor.components else {
            fatalError("请使用RGB方式给标题颜色赋值")
        }
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}

extension SYPageTitleView {
    
    @discardableResult
    private func subButton(frame: CGRect, flag: Int, title: String?, parentView: UIView) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.tag = flag
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(titleSelectIndex(_:)), for: .touchUpInside)
        button.titleLabel?.font = layout.titleFont
        parentView.addSubview(button)
        return button
    }
}

