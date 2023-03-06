//
//  HomeListData.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import Foundation
import Alamofire
typealias HomeListCallBack  = (_ object: [HomeListData]?) -> Void

class HomeListData {
    var _id: String = ""
    var date: String = ""
    var title: String = ""
    var writer: String = ""
    var updateDate: Date = Date()
    
    static func setUp(dic: [String: Any]) -> HomeListData {
        let homeListData: HomeListData = HomeListData()
        homeListData._id = dic["_id"] as! String
        homeListData.date = dic["date"] as! String
        homeListData.title = dic["essay_title"] as! String
        homeListData.writer = dic["writter"] as! String
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let updateDate = dic["update_date"] as! String
        homeListData.updateDate = formatter.date(from: updateDate) ?? Date()
        return homeListData
    }
    
    static func getHomeList(parameters: [String: Any], callback: @escaping HomeListCallBack) {
        NetworkManager.get(url: "/api/homeList", parameters: parameters) { error, object in
            if nil == error {
                let objectArray = object as! Array<Any>
                var resultArray: [HomeListData] = []
                for obj in objectArray {
                    let dic: [String: Any] = obj as! [String: Any]
                    let homeList = HomeListData.setUp(dic: dic)
                    resultArray.append(homeList)
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
