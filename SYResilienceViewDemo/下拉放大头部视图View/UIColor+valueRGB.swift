//
//  UIColor+valueRGB.swift
//  Nongjibang
//
//  Created by xiyang on 2017/7/26.
//  Copyright © 2017年 xiyang. All rights reserved.
//

import UIKit

extension UIColor{
    
    // 便利初始化方法
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    //用数值初始化颜色，便于生成设计图上标明的十六进制颜色
    convenience init(hexString: String) {
        
        var cStr : String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cStr.hasPrefix("#") {
            let index = cStr.index(after: cStr.startIndex)
            let endIndex = cStr.endIndex
            cStr = String(cStr[index ..< endIndex])
        }
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        if cStr.count == 6 {
            
            let rRange = cStr.startIndex ..< cStr.index(cStr.startIndex, offsetBy: 2)
            let rStr = String(cStr[rRange])
            
            let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
            let gStr = String(cStr[gRange])
            
            let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
            let endIndex = cStr.endIndex
            let bStr = String(cStr[bIndex ..< endIndex])
            
            Scanner(string: rStr).scanHexInt32(&r)
            Scanner(string: gStr).scanHexInt32(&g)
            Scanner(string: bStr).scanHexInt32(&b)
        }
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    static var buttonThemeColor: UIColor{
        return UIColor(hexString: "#EB6B32")
    }
    
    static var lightThemeColor: UIColor{
        return UIColor(hexString: "#FADAC9")
    }
    //主题颜色
    static var themeColor: UIColor{
        return UIColor(hexString: "#EA5904")
    }

    static var gray2Color: UIColor {
        return UIColor(hexString: "222222")
    }
    
    static var gray3Color: UIColor {
        return UIColor(hexString: "333333")
    }
    static var gray4Color: UIColor {
        return UIColor(hexString: "444444")
    }
    static var gray6Color: UIColor{
        return UIColor(hexString: "666666")
    }
    static var gray8Color: UIColor {
        return UIColor(hexString: "888888")
    }
    static var gray9Color: UIColor{
        return UIColor(hexString: "999999")
    }
    static var grayCColor: UIColor{
        return UIColor(hexString: "cccccc")
    }
    
    static var seperatorGrayColor: UIColor{
        return UIColor(hexString: "E5E5E5")
    }
    
    static var buttonGray:UIColor{
        return UIColor(hexString: "#D8D8D8")
    }
    static var backGray:UIColor{
        return UIColor(hexString: "#F3F3F3")
    }
    static var lineGray:UIColor{
        return UIColor(hexString: "#E6E6E6")
    }
    
  
   
   
   
  
}
