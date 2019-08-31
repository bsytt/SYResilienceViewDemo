//
//  UIImageExtension.swift
//  Nongjibang
//
//  Created by qiaoxy on 2019/7/5.
//  Copyright © 2019 qiaoxy. All rights reserved.
//

import Foundation
import UIKit
import Accelerate


extension UIImage{
    
    //增加模糊的效果（需要添加Accelerate.Framework）
    func gaosiBlur(blur:Double) ->UIImage{
        var blurAmount = blur//高斯模糊参数(0-1)之间，超出范围强行转成0.5
        if (blurAmount < 0.0||blurAmount > 1.0) {
            blurAmount = 0.5
        }
        var boxSize = Int(blurAmount * 40)
        boxSize = boxSize - (boxSize % 2) + 1
        let img = self.cgImage
        var inBuffer = vImage_Buffer()
        var outBuffer = vImage_Buffer()
        let inProvider = img!.dataProvider
        let inBitmapData = inProvider!.data
        inBuffer.width=vImagePixelCount(img!.width)
        inBuffer.height=vImagePixelCount(img!.height)
        inBuffer.rowBytes = img!.bytesPerRow
        inBuffer.data = UnsafeMutableRawPointer(mutating:CFDataGetBytePtr(inBitmapData))
        //手动申请内存
        let pixelBuffer = malloc(img!.bytesPerRow * img!.height)
        outBuffer.width = vImagePixelCount(img!.width)
        outBuffer.height = vImagePixelCount(img!.height)
        outBuffer.rowBytes = img!.bytesPerRow
        outBuffer.data = pixelBuffer
        var error = vImageBoxConvolve_ARGB8888(&inBuffer,&outBuffer,nil,vImagePixelCount(0),vImagePixelCount(0),UInt32(boxSize),UInt32(boxSize),nil,vImage_Flags(kvImageEdgeExtend))
        if (kvImageNoError != error) {
            error = vImageBoxConvolve_ARGB8888(&inBuffer,&outBuffer,nil,vImagePixelCount(0),vImagePixelCount(0),UInt32(boxSize),UInt32(boxSize),nil,vImage_Flags(kvImageEdgeExtend))
            if (kvImageNoError != error) {
                error = vImageBoxConvolve_ARGB8888(&inBuffer,&outBuffer,nil,vImagePixelCount(0),vImagePixelCount(0),UInt32(boxSize),UInt32(boxSize),nil,vImage_Flags(kvImageEdgeExtend))
                
            }
            
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: outBuffer.data,width:Int(outBuffer.width),height:Int(outBuffer.height),bitsPerComponent:8,bytesPerRow: outBuffer.rowBytes,space: colorSpace,bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)
        let imageRef = ctx!.makeImage()
        //手动申请内存
        free(pixelBuffer)
        return UIImage(cgImage: imageRef!)
        
    }
    
   
}


