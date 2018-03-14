//
//  AlbumModel.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/25.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit

class AlbumModel: NSObject {
    
    func getPhotos() -> [UIImage] {
        var res: [UIImage] = []
        for i in 1...37 {
            let filename = "Photos/\(i).jpg"
            if let image = UIImage(named: filename) {
                res.append(image)
            }
        }
        print("total: \(res.count) images from Photos Dir")
        return res
    }
    
}
