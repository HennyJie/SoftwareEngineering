//
//  ApiCnfig.swift
//  EasySearch
//
//  Created by l_yq on 2018/1/5.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ApiCnfigModel: NSObject {
    let apiurl: String = "http://115.159.33.179/hasou/api/index.php"
    let apiroot: String = "http://115.159.33.179/hasou/api/"
    let appid: String = "miao_id"
    let appkey: String = "miao_key"
    
    static var conf = URLSessionConfiguration.default
    static let manager = Alamofire.SessionManager(configuration: conf)
    
    override init() {
        super.init()
        ApiCnfigModel.conf.timeoutIntervalForRequest = 5
    }
    
    // 1. query email exists or not
    // 2. check (email, password) is valid or not
    // 3. insert (email, password)
    // 4. update (email, password*)
    
    enum QueryCase {
        case CheckEmail
        case CheckEmailAndPwd
        case GetBalance
        case PhotoURL
        case CheckVIP
//        case Default
    }
    
    enum ConErrorType {
        case ConFailed     // can't connect to the server
        case JsonTypeError // return a invalid json
        case ConvertError  // can't convert data to image
    }
    
    enum PaymenType {
        case Recharge
        case BuyVIP
//        case Default
    }
    
    // different url to do different actions
    private func apiForQuery(qcase: QueryCase) -> String {
        // select ...
        // .get
        var res: String = apiurl
        switch qcase {
        case .CheckEmail: res += "/checkemail"
        case .CheckEmailAndPwd: res += "/checkemail/andpwd"
        case .GetBalance: res += "/getbalance"
        case .PhotoURL: res += "/photourl"
        case .CheckVIP: res += "/checkvip"
        default: break
        }
        return res
    }
    
    private func apiForPayment(pcase: PaymenType) -> String {
        var res: String = apiurl + "/pay"
        switch pcase {
        case .Recharge:
            res += "/recharge"
        case .BuyVIP:
            res += "/buyvip"
        default:
            break
        }
        return res
    }
    
    private func apiForInsert() -> String {
        // insert ...
        // .post
        return apiurl + "/register"
    }
    
    private func apiForUpdata() -> String {
        // update and delete ...
        // .put
        return apiurl
    }
    
    func getimageurl(url: String, complete: @escaping (UIImage?, Bool,
        ApiCnfigModel.ConErrorType?) -> ()) {
        
        let imURL = "http://115.159.33.179/hasou/api/" + url
        // 拿到头像的路径了
        ApiCnfigModel.manager.request(imURL).responseData { (response) in
            if let data = response.value {
                if let image = UIImage(data: data) {
                    complete(image, true, nil)
                    print("success.")
                } else {
                    // 收到的数据有误
                    print("Convert Error: can't convert response data to image.(image not found.)")
                    complete(nil, false, nil)
                }
            } else {
                print("Connect Error: response value is nil.")
                complete(nil, false, nil)
            }
        }
    }
    
    func hasouQueryImage(word: String, complete: @escaping (UIImage?, Bool, Bool, ApiCnfigModel.ConErrorType?) -> ()) {
        let param: Parameters = [
            "word": word,
            "dir": String(Int(NSDate().timeIntervalSince1970))
        ]
        
        let url = "http://115.159.33.179/hasou/api/index.php" + "/queryimageurl"
        
        ApiCnfigModel.manager.request(url, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { (response) in
            if let reValue = response.value {
                print(response.value!)
                let json = JSON(reValue)
                // if json[xxx] dosen't exist, it return a JSON.null.
                if json["info"] != JSON.null {
                    let info = json["info"]
                    guard info == "Success" && json["data"]["res"] != JSON.null else {
                        print("Connect Error: \(info) with error code \(json["status"]).")
                        complete(nil, false, false, .JsonTypeError)
                        return
                    }
                    
                    print(json["data"]["res"])
                    let res = (json["data"]["res"] == "yes")
                    
                    if res {
                        self.getimageurl(url: String(describing: json["data"]["url1"]), complete: { (image, res, error) in
                            if res {
                                complete(image, true, true, nil)
                            } else {
                                complete(nil, true, false, nil)
                            }
                        })
                        self.getimageurl(url: String(describing: json["data"]["url2"]), complete: { (image, res, error) in
                            if res {
                                complete(image, true, true, nil)
                            } else {
                                complete(nil, true, false, nil)
                            }
                        })
                        self.getimageurl(url: String(describing: json["data"]["url3"]), complete: { (image, res, error) in
                            if res {
                                complete(image, true, true, nil)
                            } else {
                                complete(nil, true, false, nil)
                            }
                        })
                    } else {
                        complete(nil, false, false, .JsonTypeError)
                    }
                    
                } else {
                    print("Connect Error: response value is not a valid json string.")
                    complete(nil, false, false, .JsonTypeError)
                }
            } else {
                print("Connect Error: response value is nil.")
                complete(nil, false, false, .ConFailed)
            }
        }
    }
    
    func hasouCheckVIP(uemail: String, complete: @escaping (Bool, Bool, ApiCnfigModel.ConErrorType?) -> ()) {
        hasouGetVIPExpireTime(uemail: uemail) { (res, time, error) in
            if res {
                let nowDate = String(describing: Date())
                print(time)
                print(nowDate)
                print(nowDate < time)
                complete(true, nowDate < time, nil)
            } else {
                complete(false, false, error)
            }
        }
    }
    
    func hasouGetVIPExpireTime(uemail: String, complete: @escaping (Bool, String, ApiCnfigModel.ConErrorType?) -> ()) {
        let param: Parameters = [
            "appid": appid,
            "appkey": appkey,
            "data": [
                "uemail": uemail
            ]
        ]
        
        ApiCnfigModel.manager.request(apiForQuery(qcase: .CheckVIP), method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { (response) in
            if let reValue = response.value {
                print(response.value!)
                let json = JSON(reValue)
                // if json[xxx] dosen't exist, it return a JSON.null.
                if json["info"] != JSON.null {
                    let info = json["info"]
                    guard info == "Success" && json["data"]["res"] != JSON.null else {
                        print("Connect Error: \(info) with error code \(json["status"]).")
                        complete(false, "null", .JsonTypeError)
                        return
                    }
                    
                    print(json["data"]["res"])
                    let res = (json["data"]["res"] == "yes")
                    
                    complete(res, String(describing: json["data"]["time"]), nil)
                    
                } else {
                    print("Connect Error: response value is not a valid json string.")
                    complete(false, "null", .JsonTypeError)
                }
            } else {
                print("Connect Error: response value is nil.")
                complete(false, "null", .ConFailed)
            }
        }
    }
    
    func hasouPay(uemail: String, upwd: String, account: Double, pcase: ApiCnfigModel.PaymenType,complete: @escaping (Bool, Double, ApiCnfigModel.ConErrorType?) -> ()) {
        let param: Parameters = [
            "appid": appid,
            "appkey": appkey,
            "data": [
                "uemail": uemail,
                "upwd": upwd,
                "account": String(account)
            ]
        ]
        
        ApiCnfigModel.manager.request(apiForPayment(pcase: pcase), method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { (response) in
            if let reValue = response.value {
                print(response.value!)
                let json = JSON(reValue)
                // if json[xxx] dosen't exist, it return a JSON.null.
                if json["info"] != JSON.null {
                    let info = json["info"]
                    guard info == "Success" && json["data"]["res"] != JSON.null else {
                        print("Connect Error: \(info) with error code \(json["status"]).")
                        complete(false, 0.0, .JsonTypeError)
                        return
                    }
                    
                    print(json["data"]["res"])
                    let res = (json["data"]["res"] == "yes")
                    
                    if let balance = Double(String(describing: json["data"]["account"])) {
                        complete(res, balance, nil)
                    } else {
                        complete(res, 0.0, nil)
                    }
                    
                } else {
                    print("Connect Error: response value is not a valid json string.")
                    complete(false, 0.0, .JsonTypeError)
                }
            } else {
                print("Connect Error: response value is nil.")
                complete(false, 0.0, .ConFailed)
            }
        }
    }
    
    func hasouGetBalance(uemail: String, complete: @escaping (Bool, Double, ApiCnfigModel.ConErrorType?) -> ()) {
        let param: Parameters = [
            "appid": appid,
            "appkey": appkey,
            "data": [
                "uemail": uemail
            ]
        ]
        
        ApiCnfigModel.manager.request(apiForQuery(qcase: .GetBalance), method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { (response) in
            if let reValue = response.value {
                print(response.value!)
                let json = JSON(reValue)
                // if json[xxx] dosen't exist, it return a JSON.null.
                if json["info"] != JSON.null {
                    let info = json["info"]
                    guard info == "Success" && json["data"]["res"] != JSON.null else {
                        print("Connect Error: \(info) with error code \(json["status"]).")
                        complete(false, 0.0, .JsonTypeError)
                        return
                    }
                    
                    print(json["data"]["res"])
                    let res = (json["data"]["res"] == "yes")
                    
                    if let balance = Double(String(describing: json["data"]["balance"])) {
                        complete(res, balance, nil)
                    } else {
                        complete(false, 0.0, nil)
                    }
                    
                } else {
                    print("Connect Error: response value is not a valid json string.")
                    complete(false, 0.0, .JsonTypeError)
                }
            } else {
                print("Connect Error: response value is nil.")
                complete(false, 0.0, .ConFailed)
            }
        }
    }
    
    func hasouGetPhoto(uemail: String, complete: @escaping (Bool, UIImage?, ApiCnfigModel.ConErrorType?) -> ()) {
        let param: Parameters = [
            "appid": appid,
            "appkey": appkey,
            "data": [
                "uemail": uemail
            ]
        ]
        
        ApiCnfigModel.manager.request(apiForQuery(qcase: .PhotoURL), method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { (response) in
            if let reValue = response.value {
                print(response.value!)
                let json = JSON(reValue)
                // if json[xxx] dosen't exist, it return a JSON.null.
                var photoURL: String = ""
                var res: Bool = false
                if json["info"] != JSON.null {
                    let info = json["info"]
                    guard info == "Success" && json["data"]["res"] != JSON.null else {
                        print("Connect Error: \(info) with error code \(json["status"]).")
                        return
                    }
                    
                    print(json["data"]["res"])
                    res = (json["data"]["res"] == "yes")
                    photoURL = String(describing: json["data"]["url"])
                } else {
                    print("Connect Error: response value is not a valid json string.")
                }
                
                if res {
                    print(self.apiroot+photoURL)
                    // 拿到头像的路径了
                    Alamofire.request(self.apiroot+photoURL).responseData { (response) in
                        
                        if let data = response.value {
                            if let image = UIImage(data: data) {
                                // 拉下来的value可以转变成image
//                                if let tmpData = UserDefaults.standard.data(forKey: "uphoto") {
//                                    // 在userdefault找到uphoto
//                                    // local image found.
//                                    if let imageFromLocal = NSKeyedUnarchiver.unarchiveObject(with: tmpData) as? UIImage {
//                                        // 可以转换成UIImage
//                                        if ImageCode.isTheSameImage(image: imageFromLocal, toMatch: image) {
//                                            // 两张图片是一样的
//                                            complete(false, nil, nil)
//                                        } else {
//                                            // 两张图片不一样，更新为最新的
//                                            let data2: Data = NSKeyedArchiver.archivedData(withRootObject: image)
//                                            UserDefaults.standard.setValue(data2, forKey: "uphoto")
//                                            complete(true, image, nil)
//                                        }
//                                    } else {
//                                        // 不能转换成UIImage，更新为最新的
//                                        let data2: Data = NSKeyedArchiver.archivedData(withRootObject: image)
//                                        UserDefaults.standard.setValue(data2, forKey: "uphoto")
//                                        complete(true, image, nil)
//                                    }
//                                } else {
//                                    // 在userdefault中没有找到uphoto，更新为最新的
//                                    // key: uphoto not found.
//                                    let data2: Data = NSKeyedArchiver.archivedData(withRootObject: image)
//                                    UserDefaults.standard.setValue(data2, forKey: "uphoto")
//                                    complete(true, image, nil)
//                                }
                                complete(true, image, nil)
                                
                            } else {
                                // 收到的数据有误
                                print("Convert Error: can't convert response data to image.(image not found.)")
                                complete(false, nil, .ConvertError)
                            }
                        } else {
                            print("Connect Error: response value is nil.")
                            complete(false, nil, .ConFailed)
                        }
                    }
                }
            } else {
                print("Connect Error: response value is nil.")
            }
        }
        
    }
    
    func hasouInster(uname: String, uemail: String, upwd: String, uphoto: UIImage, complete: @escaping (Bool, ApiCnfigModel.ConErrorType?) -> ()) {
        let param = [
            "appid": appid,
            "appkey": appkey,
            "uname": uname,
            "uemail": uemail,
            "upwd": upwd
        ]
        
        let imageData = UIImagePNGRepresentation(uphoto)
        
        let filename: String = String(Int(NSDate().timeIntervalSince1970)) + String(ImageCode(image: uphoto).code) + ".png"
        
        ApiCnfigModel.manager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData!, withName: "uphoto", fileName: filename, mimeType: "image/png")
            for (key, value) in param {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, to: apiForInsert(), encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    // parse return message.
                    if let reValue = response.value {
                        print(reValue)
                        let json = JSON(reValue)
                        
                        // if json[xxx] dosen't exist, it return a JSON.null.
                        if json["info"] != JSON.null {
                            let info = json["info"]
                            guard info == "Success" && json["data"]["res"] != JSON.null else {
                                print("Connect Error: \(info) with error code \(json["status"]).")
                                complete(false, .JsonTypeError)
                                return
                            }
                            
                            print(json["data"]["res"])
                            
                            let res = (json["data"]["res"] == "yes")
                            
                            // return to deque.main.
                            complete(res, nil)
                            
                            // do something
                        } else {
                            print("Connect Error: response value is not a valid json string.")
                            complete(false, .JsonTypeError)
                        }
                    } else {
                        print("Connect Error: response value is nil.")
                        complete(false, .ConFailed)
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func hasouCheckUser(uemail: String, upwd: String? = nil, complete: @escaping (Bool, String,  ApiCnfigModel.ConErrorType?) -> ()) {
        var param: Parameters
        var reURL: URL
        
        if upwd == nil {
            // query uemail exists nor not
            param = [
                "appid": appid,
                "appkey": appkey,
                "data" : [
                    "uemail": uemail
                ]
            ]
            
            reURL = URL(string: apiForQuery(qcase: .CheckEmail))!
        } else {
            param = [
                "appid": appid,
                "appkey": appkey,
                "data" : [
                    "uemail": uemail,
                    "upwd": upwd!
                ]
            ]
            
            reURL = URL(string: apiForQuery(qcase: .CheckEmailAndPwd))!
        }
        print(param)
        
        ApiCnfigModel.manager.request(reURL, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { (response) in
            if let reValue = response.value {
                print(response.value!)
                let json = JSON(reValue)
                // if json[xxx] dosen't exist, it return a JSON.null.
                if json["info"] != JSON.null {
                    let info = json["info"]
                    guard info == "Success" && json["data"]["res"] != JSON.null else {
                        print("Connect Error: \(info) with error code \(json["status"]).")
                        complete(false, "Name", .JsonTypeError)
                        return
                    }
                    
                    print(json["data"]["res"])
                    
                    let res = (json["data"]["res"] == "yes")
                    let name_tmp = json["data"]["uname"] == JSON.null ? "Name" : json["data"]["uname"]
                    let name = String(describing: name_tmp)
                    
                    // return to deque.main.
                    complete(res, name, nil)
                    
                    // do something
                } else {
                    print("Connect Error: response value is not a valid json string.")
                    complete(false, "Name", .JsonTypeError)
                }
            } else {
                print("Connect Error: response value is nil.")
                complete(false, "Name", .ConFailed)
            }
        }
        
    }
    
}
