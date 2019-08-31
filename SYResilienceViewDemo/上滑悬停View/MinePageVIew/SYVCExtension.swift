//
//  SYVCExtension.swift
//  SYScrollView
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    private struct SYVCKey {
        static var sKey = "sy_scrollViewKey"
        static var oKey = "sy_upOffsetKey"
    }
    
    @objc public var sy_scrollView: UIScrollView? {
        get { return objc_getAssociatedObject(self, &SYVCKey.sKey) as? UIScrollView }
        set { objc_setAssociatedObject(self, &SYVCKey.sKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var sy_upOffset: String? {
        get { return objc_getAssociatedObject(self, &SYVCKey.oKey) as? String }
        set { objc_setAssociatedObject(self, &SYVCKey.oKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

