//
//  HistoryImageModel.swift
//  TestAlamofire
//
//  Created by l_yq on 2018/1/11.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class HistoryImageModel: NSObject {
    
    static let dir: String = NSHomeDirectory() + "/Documents/HistoryCache"
    
    private static func getFileManager() -> FileManager {
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: dir)
        if !exist {
            try! fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        }
        return fileManager
    }
    
    static func loadHistoryTable() -> [UIImage] {
        
        print("History Image Model: Load Image Table.")
        var res: [UIImage] = []
        let manager = HistoryImageModel.getFileManager()
        
        if let contenOfPath = try? manager.contentsOfDirectory(atPath: dir) {
            for item in contenOfPath {
                if let image = UIImage(contentsOfFile: dir + "/" + item) {
                    res.append(image)
                }
            }
        }
        // TODO: sort by create time
        print("table count: \(res.count)")
        
        return res
    }
    
    static func insertImage(image: UIImage) {
        print("History Image Model: Insert Image into Table.")
        
        var newImage: UIImage = image
        
        let areaOfImage:Double = Double(image.size.width * image.size.height)
        if areaOfImage > (300*300) {
            let ratio = sqrt(areaOfImage / (300.0*300.0))
            newImage = image.scaleImage(scaleSize: CGFloat(1.0/ratio))
            print(newImage.size)
        }
        
        let imagePath = dir + "/" + String(describing: ImageCode(image: newImage).code) + ".png"
        let data: Data = UIImagePNGRepresentation(newImage)!
        try? data.write(to: URL(fileURLWithPath: imagePath))
        print("History Image Model: Save Finished.")
    }
    
    static func clearImageTable() {
        print("History Image Model: Clear Image Table.")
        let manager = HistoryImageModel.getFileManager()
        try! manager.removeItem(atPath: dir)
        try! manager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        print("History Image Model: Clear Finished.")
    }
}

