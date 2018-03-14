//
//  ImageProcModel.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/27.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit

class ImageProcModel: NSObject {
    func cvToGray(_ image: UIImage) -> UIImage{
        return OpenCVWrapper.makeGray(from: image)
    }
    
    func cvLighting(_ image: UIImage) -> UIImage {
        return OpenCVWrapper.lightingImage(image)!
    }
    
    func cvSiftMatch(_ image: UIImage) -> [UIImage]? {
        return nil
    }
    
    func cvDefog(_ image: UIImage) -> UIImage {
        return OpenCVWrapper.defog(image)!
    }
    
    func cvTailor(_ imageSet: [UIImage]) -> UIImage {
        return OpenCVWrapper.tailerImage(imageSet)!
    }
}
