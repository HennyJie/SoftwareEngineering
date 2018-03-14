//
//  OCRModel.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/14.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit
import TesseractOCR

class OCRModel: NSObject {
    
    var imageTable: [UIImage] = []
    var isLoad: Bool = false
    var delegate: OCRModelDelegate?
    
    
    // search from the Album, find the most ... one(or 5...) and return
    // not order
    // if there are not any image matched, return nil.
    func searchFromTheAlbum(_ target: String) -> [UIImage] {
        // for each photo from ablum
        //  if image code exist and the ocr string is computed
        //   try to match it
        //   if success => add to retult image set
        //  else
        //   compute the ocr string of the image
        //   update image code table
        //   try to match ... (same ops)
        // if result set is empty return nil
        // else return image set
        
        if !isLoad {
            imageTable = AlbumModel().getPhotos()
            isLoad = true
        }
        
        var result: [UIImage] = []
        let imageCodeModel: ImageCodeModel = ImageCodeModel()
        imageCodeModel.loadTable()
        
        
        for i in 0..<imageTable.count {
            if delegate?.isStopped() ?? true {
                print("OCRSEARCH: stop this searching, break and save table to ud.")
                break
            }
            
            autoreleasepool {
                let image = imageTable[i]
                print("OCRSEARCH: ==========image \(i+1), total \(imageTable.count)==========")
                // find this code from the table, use the ocr string in this code
                if let codeFromTable = imageCodeModel.search(code: ImageCode(image: image).code) {
                    print("OCRSEARCH: find this code from code table.")
                    
                    if codeFromTable.ocrString == nil {
                        print("OCRSEARCH: ocr string has not been detected.")
                        
                        codeFromTable.ocrString = OCRtoImage(image)
                    }
                    
                    // match this ocr string with input string
                    if matchString(target, toMatch: codeFromTable.ocrString!) {
                        print("OCRSEARCH: match no.\(i) photo from image table")
                        
                        result.append(image)
                    }
                    
                } else {
                    print("OCRSEARCH: can't find this code from code table")
                    
                    let imageCode = ImageCode(image: image)
                    imageCode.ocrString = OCRtoImage(image)
                    
                    if matchString(target, toMatch: imageCode.ocrString!) {
                        print("OCRSEARCH: match no.\(i) photo from image table")
                        
                        result.append(image)
                    }
                    
                    print("OCRSEARCH: insert code from no.\(i) image")
                    imageCodeModel.insert(code: imageCode)
                }
                
                delegate?.progressOfSearch(now: i+1, total: imageTable.count)
            }
            
        }
        
        imageCodeModel.saveTable()
        print("total find: \(result.count)")
        return result
    }
    
    // try to match the ocr string with the image's from the album
    private func matchString(_ s: String, toMatch: String) -> Bool{
        var res: Int = 0
        for item in s {
            if toMatch.contains(item) {
                res += 1
            }
        }
        
        return (Float(res) / Float(s.count)) > 0.5
    }
    
    private func applyOCRtoImage(_ image: UIImage) -> String {
        
        // ...
        // use TesseractOCR to get String from image(images -> 2 states)
        // split empty characters
        
        return ""
    }
    
    
    // use OCR to get string from image
    private func OCRtoImage(_ image: UIImage) -> String {
        var resizedImage = image
        if image.size.width * image.size.height > 1000 * 1000 {
            print(image.size)
            let ratio_w = image.size.width / 1000.0
            let ratio_h = image.size.height / 1000.0
            let res_w = image.size.width / max(ratio_h, ratio_w)
            let res_h = image.size.height / max(ratio_h, ratio_w)
            resizedImage = OpenCVWrapper.resize(image, toSize: Int32(res_w), andCol: Int32(res_h))!
            print(resizedImage.size)
        }
        if let tesseract = G8Tesseract(language: "eng+chi_sim") {
            tesseract.pageSegmentationMode = .auto
            tesseract.image = resizedImage.g8_blackAndWhite()
            tesseract.recognize()
            return tesseract.recognizedText
        }
        return ""
    }
    
    // TODO: Int: 64 bit or use string[64]
    private func updateCodeTable(code: Int, ocrString: String) {
        
    }
}

protocol OCRModelDelegate {
    // update your ui
    func progressOfSearch(now: Int, total: Int)
    func isStopped() -> Bool
}
