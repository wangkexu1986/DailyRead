//
//  LoginData.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import Foundation
import Alamofire
typealias RegisterCallBack  = (_ object: String?) -> Void
typealias LoginCallBack  = (_ object: String?, _ userId: String?, _ userName: String?) -> Void

class LoginData {
    
    //注册
    static func postRegister(parameters: [String: String], callback: @escaping RegisterCallBack) {
        let postUrl = "/api/register"
        NetworkManager.post(url: postUrl, parameters: parameters) { error, object in
            if nil == error {
                var result: String = ""
                if nil != object{
                    let objectDic = object?["data"] as! [String: Any]
                    result = objectDic["result"] as! String
                }
                callback(result)
            } else {
                callback("failure")
            }
        }
    }
    
    //登陆
    static func postLogin(parameters: [String: String], callback: @escaping LoginCallBack) {
        let postUrl = "/api/login"
        NetworkManager.post(url: postUrl, parameters: parameters) { error, object in
            if nil == error {
                var result: String = ""
                var userId: String = ""
                var userName: String = ""
                if nil != object{
                    let objectDic = object?["data"] as! [String: Any]
                    result = objectDic["result"] as! String
                    if result == "success" {
                        if objectDic.keys.contains("_id"){
                            userId = objectDic["_id"] as! String
                        }
                        if objectDic.keys.contains("user_nickname") {
                            userName = objectDic["user_nickname"] as! String
                        }
                    }
                }
                callback(result, userId, userName)
            } else {
                callback("failure", "", "")
            }
        }
    }
}
