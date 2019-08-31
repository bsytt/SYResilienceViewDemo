//
//  SYCollectionFlowLayout.swift
//  SYScrollView_Example
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import UIKit

extension UICollectionViewFlowLayout {
    
    private struct SYCollectionViewHandleKey {
        static var key = "sy_collectionViewContentSizeHandle"
    }
    
    public static var sy_sliderHeight: CGFloat? {
        get { return objc_getAssociatedObject(self, &SYCollectionViewHandleKey.key) as? CGFloat }
        set { objc_setAssociatedObject(self, &SYCollectionViewHandleKey.key, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    public class func loadOnce() {
        DispatchQueue.once(token: "SYFlowLayout") {
            let originSelector = #selector(getter: UICollectionViewLayout.collectionViewContentSize)
            let swizzleSelector = #selector(UICollectionViewFlowLayout.sy_collectionViewContentSize)
            sy_swizzleMethod(self, originSelector, swizzleSelector)
        }
    }
    
    @objc dynamic func sy_collectionViewContentSize() -> CGSize {
        
        let contentSize = self.sy_collectionViewContentSize()
        
        guard let collectionView = collectionView else { return contentSize }
        
        guard let sy_sliderHeight = UICollectionViewFlowLayout.sy_sliderHeight, sy_sliderHeight > 0 else { return contentSize }
        
        let collectionViewH = collectionView.bounds.height - sy_sliderHeight
        
        return contentSize.height < collectionViewH ? CGSize(width: contentSize.width, height: collectionViewH) : contentSize
    }
}
