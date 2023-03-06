//
//  AssayData.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/24.
//


import Foundation
import Alamofire
typealias uploadEssayCallBack  = (_ result: String?, _ fileName: String?) -> Void
typealias createEssayCallBack  = (_ result: String?) -> Void
typealias essayCallBack  = (_ error: Error?, _ result: EssayData?) -> Void
typealias recordCallBack  = (_ error: Error?, _ data: Data?) -> Void

class EssayData {
    var _id: String = ""
    var essayTitle: String = ""
    var essayContent: String = ""
    var essayRecord: String = ""
    var createDate: Date = Date()
    var updateDate: Date = Date()
    var createUser: String = ""
    var updateUser: String = ""
    
    static func setUpEssayData(object: [String: Any]) -> EssayData{
        let essayData = EssayData.init()
        essayData._id = object["_id"] as! String
        essayData.essayTitle = object["essay_title"] as! String
        essayData.essayContent = object["essay_content"] as! String
        essayData.essayRecord = object["essay_record"] as! String
        essayData.createUser = object["create_user"] as! String
        essayData.updateUser = object["update_user"] as! String
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let createDate = object["create_date"] as! String
        essayData.createDate = formatter.date(from: createDate) ?? Date()
        let updateDate = object["update_date"] as! String
        essayData.updateDate = formatter.date(from: updateDate) ?? Date()
        return essayData
    }
    
    static func uploadEssayRecord(fileData: Data, callback: @escaping uploadEssayCallBack) {
        NetworkManager.upload(url: "/api/uploadEssayFile", fileData: fileData) { error, object in
            if nil == error {
                let result = object?["result"] as! String
                let fileName = object?["filePath"] as! String
                callback(result, fileName)
            } else {
                callback("failure", "")
            }
        }
    }
    
    static func postCreateEssay(parameters: [String: Any], callback: @escaping createEssayCallBack) {
        NetworkManager.post(url: "/api/createEssay", parameters: parameters) { error, object in
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
    
    static func getEssayContent(parameters: [String: Any], callback: @escaping essayCallBack) {
        NetworkManager.get(url: "/api/getEssay", parameters: parameters) { error, object in
            if nil == error {
                if nil != object{
                    let result = object as! [Any]
                    let essay = self.setUpEssayData(object: result[0] as! [String: Any])
                    callback(error, essay)
                }
            } else {
                callback(error, nil)
            }
        }
    }
    
    static func downloadRecord(parameters: [String: Any], callback: @escaping recordCallBack) {
        let fileName = parameters["fileName"] as! String
        let directorys = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = directorys.first
        let downloadFileDirectory = documentDirectory! + "/download"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: downloadFileDirectory + "/\(fileName)") {
            let cacheFileURL = URL.init(fileURLWithPath: downloadFileDirectory + "/\(fileName)")
            do {
                let data = try Data.init(contentsOf: cacheFileURL)
                callback(nil, data)
            } catch {
                
            }
            return
        }
        
        NetworkManager.download(url: "/api/downloadRecord", parameters: parameters) { error, object in
            if nil == error {
                if nil != object{
                    //cache
                    //  创建录音的文件夹
                    if !fileManager.fileExists(atPath: downloadFileDirectory) {
                        try? fileManager.createDirectory(at: URL.init(fileURLWithPath: downloadFileDirectory), withIntermediateDirectories: true, attributes: nil)
                    }
                    else {
                        let items = FileManager.default.subpaths(atPath: downloadFileDirectory)
                        print("子文件：",items)
                    }
                    let filePath = downloadFileDirectory + "/\(fileName)"
                    fileManager.createFile(atPath: filePath, contents:nil, attributes:nil)
                    let fileHandle = FileHandle(forWritingAtPath: filePath)!
                    fileHandle.write(object!)
                    try? fileHandle.close()
                    
                    callback(error, object)
                }
            } else {
                callback(error, nil)
            }
        }
    }
}
