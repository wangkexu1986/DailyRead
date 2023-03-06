//
//  ReadData.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/27.
//

import Foundation
import Alamofire
typealias uploadReadCallBack  = (_ result: String?, _ fileName: String?) -> Void
typealias recordListCallBack  = (_ readRecordList: [ReadRecordData]) -> Void

class ReadRecordData {
    var _id: String = ""
    var userId: String = ""
    var readRecord: String = ""
    var postDate: String = ""
    var userName: String = ""
    var recordTime: String = ""
    var updateDate: Date = Date()
    
    static func setUpReadRecordData(object: [String: Any]) -> ReadRecordData{
        var readRecordData = ReadRecordData.init()
        readRecordData.userId = object["_id"] as! String
        readRecordData.userId = object["user_id"] as! String
        readRecordData.readRecord = object["read_record"] as! String
        readRecordData.userName = object["user"] as! String
        readRecordData.postDate = object["date"] as! String
        if object.keys.contains("record_time") {
            readRecordData.recordTime = object["record_time"] as! String
        }
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let updateDate = object["update_date"] as! String
        readRecordData.updateDate = formatter.date(from: updateDate) ?? Date()
        return readRecordData
    }
    
    static func uploadReadRecord(fileData: Data, callback: @escaping uploadEssayCallBack) {
        NetworkManager.upload(prefix: UserDefaults.standard.string(forKey: LOGIN_USER_NAME)!, url: "/api/uploadReadFile", fileData: fileData) { error, object in
            if nil == error {
                let result = object?["result"] as! String
                let fileName = object?["filePath"] as! String
                callback(result, fileName)
            } else {
                callback("failure", "")
            }
        }
    }
    
    static func postCreateReadRecord(parameters: [String: Any], callback: @escaping createEssayCallBack) {
        NetworkManager.post(url: "/api/createReadRecord", parameters: parameters) { error, object in
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
    
    static func getReadRecordList(parameters: [String: Any], callback: @escaping recordListCallBack) {
        NetworkManager.get(url: "/api/getReadRecordList", parameters: parameters) { error, object in
            if nil == error {
                let objectArray = object as! Array<Any>
                var resultArray: [ReadRecordData] = []
                for obj in objectArray {
                    let dic: [String: Any] = obj as! [String: Any]
                    let readRecord = self.setUpReadRecordData(object: dic)
                    resultArray.append(readRecord)
                }
                resultArray = resultArray.sorted { a, b in
                    return a.updateDate > b.updateDate
                }
                callback(resultArray)
            } else {
                
            }
        }
    }
}
