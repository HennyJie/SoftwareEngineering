//
//  FeatureMap.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/14.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit

class FeatureMap: NSObject {
    
    var delegate: FeatureMapDelegate?
    
    var imageTable: [UIImage] = []
    var isLoad: Bool = false
    
    
    // return the image set that matched (from album)
    // order by number of matched points decresingly
    // if all of the matched points are none, return nil
    func searchFromConvasImage(_ image1: UIImage) -> [UIImage]? {
        // get the key point of input image
        
        // for each photo from album
        //  if image code exist and the feature is detected
        //    compute the number of ... :
        //    num = match2...(in, toMatch)...
        //    if num >= 1 add it to result image set
        //  else
        //    get key point from ...
        //    update image code table
        //    compute the number of ...
        //    ...
        // chose the rank ... images and return.
        // if none of images matched, return nil
        
//        let image = #imageLiteral(resourceName: "drawTest")
        let image = resizeImage(image1, size: 400.0)
        
        if !isLoad {
            imageTable = AlbumModel().getPhotos()
            isLoad = true
        }
        
        var result: [UIImage] = []
        var rank: [(UIImage, Int)] = []
        
        for i in 0..<imageTable.count {
            if delegate?.isStopped() ?? true {
                print("FEATURE MAP: stop this searching, break and save table uo ud.")
                return result
            }
            let item = resizeImage(imageTable[i], size: 800.0)
            
            
            let matchedPairs = OpenCVWrapper.getMatchedPairs(from: image, toMatch: item)
            rank.append((imageTable[i], Int(matchedPairs)))
            print("FEATURE MAP: ====\(i+1) matched \(matchedPairs) decriptors")
            
            if i+1 < imageTable.count && i%2 == 0 {
                delegate?.progressOfSearch(now: i+1, total: imageTable.count)
            }
        }
        
        
        print("FEATURE MAP: search finished, sort result and return.")
        rank.sort { (a, b) -> Bool in
            a.1 > b.1
        }
        
        for i in 0...9 {
            result.append(rank[i].0)
            print("FEATURE MAP: rank \(i+1)'s matched des: \(rank[i].1)")
        }
        
        delegate?.progressOfSearch(now: imageTable.count, total: imageTable.count)
        
        return result
    }
    
    private func resizeImage(_ image: UIImage, size: CGFloat) -> UIImage {
        var resizedImage = image
        
        print(image.size)
        
        let ratio_w = image.size.width / size
        let ratio_h = image.size.height / size
        let res_w = image.size.width / max(ratio_h, ratio_w)
        let res_h = image.size.height / max(ratio_h, ratio_w)
        resizedImage = OpenCVWrapper.resize(image, toSize: Int32(res_w), andCol: Int32(res_h))!
        
        print(resizedImage.size)
        
        return resizedImage
    }
    
    private func getDescriptor(_ image: UIImage, size: CGFloat) -> UnbelievableDescriptor {
        var resizedImage = image
        if image.size.width * image.size.height > 1000 * 1000 {
            print(image.size)
            let ratio_w = image.size.width / size
            let ratio_h = image.size.height / size
            let res_w = image.size.width / max(ratio_h, ratio_w)
            let res_h = image.size.height / max(ratio_h, ratio_w)
            resizedImage = OpenCVWrapper.resize(image, toSize: Int32(res_w), andCol: Int32(res_h))!
            print(resizedImage.size)
        }
        
        return OpenCVWrapper.getDescriptorsFrom(resizedImage)
    }
    
    // return ??? key points list
    // TODO: define the return type
    private func getKeyPointsFromImage(_ image: UIImage) -> [UnbelievableKeyPoint] {
        
        return []
    }
    
    // return the number of matched points
    private func computeNumberOfMatchedPoint(kp: UnbelievableKeyPoint, toMatch: UnbelievableKeyPoint) -> Int {
        
        return 0
    }
    
    // TODO: code 64 bit Int, keyPointsList: to be defined
    private func updateCodeTable(code: Int, keyPointsList: String) {
        
    }
}

protocol FeatureMapDelegate {
    // update your ui
    func progressOfSearch(now: Int, total: Int)
    func isStopped() -> Bool
}
