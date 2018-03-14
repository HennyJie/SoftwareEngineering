//
//  ImageCoding.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/20.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit

enum PropertyKey: String {
    case numberKey
}

class ImageCode: NSObject, NSCoding {
    
    
    // code: 64 bit
    // 8*8 size image
    var code: Int64 = 0
    // feature list (key point, descriptors)
    var desp: UnbelievableDescriptor?
    // OCR string
    var ocrString: String?
    
    init(image: UIImage) {
        // image -> (resize) 8 * 8
        // resized image -> code: 64 bit
        code = OpenCVWrapper.encode(image)
        print("image \(image)'s code: \(code)")
    }
    
    static func isTheSameImage(image: UIImage, toMatch: UIImage) -> Bool {
        let code1 = ImageCode(image: image).code
        let code2 = ImageCode(image: toMatch).code
        
        return code1 == code2
    }
    
    func isTheSameImage(toMatch tcode: ImageCode) -> Bool{
        return self.code == tcode.code
    }
    
    func isOcrStringComputed() -> Bool {
        return self.ocrString != nil
    }
    
    func isDespComputed() -> Bool {
//        return self.desp != nil
        return false
    }
    
    // decode from nsobject
    // excuse me?? why it fucking work?
    required init(coder aDecoder: NSCoder){
        guard let myNumber = aDecoder.decodeInt64(forKey: PropertyKey.numberKey.rawValue) as Int64? else {
            return
        }
        
//        self.code = aDecoder.decodeObject(forKey: "code") as! Int64
        self.code = myNumber
        self.ocrString = aDecoder.decodeObject(forKey: "ocr") as? String
        self.desp = aDecoder.decodeObject(forKey: "descriptor") as? UnbelievableDescriptor
    }
    
    // encode to object
    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: PropertyKey.numberKey.rawValue)
        aCoder.encode(desp, forKey: "descriptor")
        aCoder.encode(ocrString, forKey:"ocr")
    }
    
    
}
