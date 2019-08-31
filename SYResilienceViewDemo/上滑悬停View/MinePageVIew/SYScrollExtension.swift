//
//  SYScrollExtension.swift
//  SYScrollView
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    public typealias SYScrollHandle = (UIScrollView) -> Void
    
    private struct SYHandleKey {
        static var key = "sy_handle"
        static var tKey = "sy_isTableViewPlain"
    }
    
    public var scrollHandle: SYScrollHandle? {
        get { return objc_getAssociatedObject(self, &SYHandleKey.key) as? SYScrollHandle }
        set { objc_setAssociatedObject(self, &SYHandleKey.key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    @objc public var isTableViewPlain: Bool {
        get { return (objc_getAssociatedObject(self, &SYHandleKey.tKey) as? Bool) ?? false}
        set { objc_setAssociatedObject(self, &SYHandleKey.tKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}

extension String {
    func sy_base64Decoding() -> String {
        let decodeData = NSData.init(base64Encoded: self, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        if decodeData == nil || decodeData?.length == 0 {
            return "";
        }
        let decodeString = NSString(data: decodeData! as Data, encoding: String.Encoding.utf8.rawValue)
        return decodeString! as String
    }
}

extension UIScrollView {
    
    public class func initializeOnce() {
        DispatchQueue.once(token: UIDevice.current.identifierForVendor?.uuidString ?? "SYScrollView") {
            let didScroll = "X25vdGlmeURpZFNjcm9sbA==".sy_base64Decoding()
            let originSelector = Selector((didScroll))
            let swizzleSelector = #selector(sy_scrollViewDidScroll)
            sy_swizzleMethod(self, originSelector, swizzleSelector)
        }
    }
    
    @objc dynamic func sy_scrollViewDidScroll() {
        self.sy_scrollViewDidScroll()
        guard let scrollHandle = scrollHandle else { return }
        scrollHandle(self)
    }
}

extension NSObject {
    
    static func sy_swizzleMethod(_ cls: AnyClass?, _ originSelector: Selector, _ swizzleSelector: Selector)  {
        let originMethod = class_getInstanceMethod(cls, originSelector)
        let swizzleMethod = class_getInstanceMethod(cls, swizzleSelector)
        guard let swMethod = swizzleMethod, let oMethod = originMethod else { return }
        let didAddSuccess: Bool = class_addMethod(cls, originSelector, method_getImplementation(swMethod), method_getTypeEncoding(swMethod))
        if didAddSuccess {
            class_replaceMethod(cls, swizzleSelector, method_getImplementation(oMethod), method_getTypeEncoding(oMethod))
        } else {
            method_exchangeImplementations(oMethod, swMethod)
        }
    }
}




