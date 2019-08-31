//
//  UIViewExtension.swift
//  Nongjibang
//
//  Created by xiyang on 2017/8/28.
//  Copyright © 2017年 gaofan. All rights reserved.
//

import Foundation
import UIKit

enum GradientType : Int {
    case topToBottom = 0  //从上到下
    case leftToRight = 1  //从左到右
    case upleftTolowRight = 2 //左上到右下
    case uprightTolowLeft = 3 //右上到左下
}

public struct UIRectSide : OptionSet {
    public let rawValue: Int
    public static let left = UIRectSide(rawValue: 1 << 0)
    public static let top = UIRectSide(rawValue: 1 << 1)
    public static let right = UIRectSide(rawValue: 1 << 2)
    public static let bottom = UIRectSide(rawValue: 1 << 3)
    public static let all: UIRectSide = [.top, .right, .left, .bottom]
    public init(rawValue: Int) {
        self.rawValue = rawValue;
    }
}

extension UIView{
    
    func viewController() -> UIViewController? {
        
        var next = self.superview
        while (next != nil) {
            let responder = next?.next
            if responder is UIViewController{
                return responder as? UIViewController
            }
            next = next?.superview
        }
        
        return nil
        
    }
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat , frames:CGRect) {
        let maskPath = UIBezierPath(roundedRect: frames, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = frames
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    //生成渐变色图片
    func backImageFromColors(colors:[UIColor],gradientType:GradientType) -> UIImage {
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 1)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let colorSpace = colors.last?.cgColor.colorSpace
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: nil)
        
        let start : CGPoint!
        let end : CGPoint!
        //        CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
        
        switch(gradientType) {
        case .topToBottom:
            start = CGPoint(x: 0.0,y: 0.0)
            end = CGPoint(x: 0.0, y: frame.size.height)
        case .leftToRight:
            start = CGPoint(x: 0.0,y: 0.0)
            end = CGPoint(x: frame.size.width,y: 0.0)
        case .upleftTolowRight:
            start = CGPoint(x: 0.0,y: 0.0)
            end = CGPoint(x: frame.size.width, y: frame.size.height)
        case .uprightTolowLeft:
            start = CGPoint(x: frame.size.width,y: 0.0)
            end = CGPoint(x: 0.0, y: frame.size.height)
        default:
            break
        }
        context?.drawLinearGradient(gradient!, start: start, end: end, options: [.drawsBeforeStartLocation,.drawsAfterEndLocation])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //画虚线边框
    func drawDashLine(strokeColor: UIColor, lineWidth: CGFloat = 1, lineLength: Int = 10, lineSpacing: Int = 5, corners: UIRectSide) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        //每一段虚线长度 和 每两段虚线之间的间隔
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        let path = CGMutablePath()
        if corners.contains(.left) {
            path.move(to: CGPoint(x: 0, y: self.layer.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        if corners.contains(.top){
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: self.layer.bounds.width, y: 0))
        }
        if corners.contains(.right){
            path.move(to: CGPoint(x: self.layer.bounds.width, y: 0))
            path.addLine(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
        }
        if corners.contains(.bottom){
            path.move(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: self.layer.bounds.height))
        }
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    //打电话
    func phoneCall(phoneStr:String){
        let phoneNum    = "tel:\(phoneStr)"
        let callWedView = UIWebView()
        let request     = URLRequest(url: URL(string:phoneNum)!)
        callWedView.loadRequest(request)
        self.addSubview(callWedView)
    }
}

