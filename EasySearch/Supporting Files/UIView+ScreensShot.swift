//
//  UIView+ScreensShot.swift
//  DrawTest
//
//  Created by l_yq on 2017/11/27.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /**
     Get the view's screen shot, this function may be called from any thread of your app.
     
     - returns: The screen shot's image.
     */
    func screenShot() -> UIImage? {
        
        guard frame.size.height > 0 && frame.size.width > 0 else {
            
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
