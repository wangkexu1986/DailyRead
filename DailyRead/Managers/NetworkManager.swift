//
//  NetworkManager.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import Foundation
import Alamofire

class NetworkManager {
  static var sessionManager:Alamofire.SessionManager!
  static let NET_TIME_OUT = 60
  typealias callbackAny  = (_ error: NSError?, _ object: Any?) -> Void
  typealias callback  = (_ error: NSError?, _ object: [String: Any]?) -> Void
  typealias callbackModel<T> = (_ error: NSError?, _ model: T ) -> Void
  typealias callbackData = (_ error: NSError?, _ data: Data?) -> Void
  // common
  class func commonRequest(url: String,
                           method: HTTPMethod,
                           parameters: Parameters?,
                           encoding: ParameterEncoding,
                           callback: @escaping (DataResponse<Any>) -> Void)
  {
    let urlString: String = getUrl(url: url)
    let header = getHTTPHeader()
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = TimeInterval(NET_TIME_OUT)
    if sessionManager == nil {
      sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
      
    let request = sessionManager.request(urlString,
                      method: method,
                      parameters: parameters,
                      encoding: encoding,
                      headers: header)
    request.responseJSON
      { (responseJSON) in
          callback(responseJSON)
          
      }
  }
  
  // get
  class func get(url: String, parameters: Parameters?, callback: @escaping callbackAny) {
    commonRequest(url: url, method: .get, parameters: parameters, encoding: URLEncoding.default, callback: { (responseJSON) in
      switch responseJSON.result {
      case .success(let jsonData):
        let json = jsonData as? [String: Any]
        let resultError = json?["errorCode"] as? Int64
        if resultError != nil {
          //todo error 処理
          let dataError = NSError.init(domain: "false", code: 404, userInfo: nil)
          callback(dataError, nil)
        } else {
          let data = json?["data"] as Any
          callback(nil, data)
        }
      case .failure(let error):
        callback(error as NSError, nil)
        print(error)
      }
    })
  }
  
  //delete
  
  class func delete(url: String, parameters: Parameters?, callback: @escaping callback) {
    commonRequest(url: url, method: .delete, parameters: parameters, encoding: URLEncoding.default, callback: { (responseJSON) in
      switch responseJSON.result {
      case .success(let jsonData):
        let json = jsonData as? [String: Any]
        let resultError = json?["errorCode"] as? Int64
        if resultError != nil {
          //todo error 処理
          let dataError = NSError.init(domain: "false", code: 404, userInfo: nil)
          callback(dataError, nil)
        } else {
          let data = json?["data"] as? [String: Any]
          callback(nil, data)
        }
      case .failure(let error):
        callback(error as NSError, nil)
        print(error)
      }
    })
  }

  // post
  class func post(url: String, parameters: Parameters?, callback: @escaping callback) {
    commonRequest(url: url, method: .post, parameters: parameters, encoding: JSONEncoding.default, callback: { (responseJSON) in
      switch responseJSON.result {
        
      case .success(let jsonData):
        let json = jsonData as? [String: Any]
        let resultError = json?["errorCode"] as? Int64
        if resultError != nil {
          let dataError = NSError.init(domain: "false", code: 404, userInfo: nil)
          callback(dataError, nil)
        } else {
          callback(nil, json)
          
        }
      case .failure(let error):
        callback(error as NSError, nil)
      }
    })
  }
    
    class func upload(prefix: String = "", url: String, fileData: Data, callback: @escaping callback) {
        let urlString: String = getUrl(url: url)
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let filename = formatter.string(from: Date())
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileData, withName: "record", fileName: prefix + "_" + "\(filename).m4a", mimeType: "audio/x-m4a")
        }, to: urlString, encodingCompletion: {result in
            switch result {
            case .success(let request, let streamingFromDisk, let streamFileURL):
                request.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let jsonData):
                        let json = jsonData as? [String: Any]
                        let resultError = json?["error"] as? [String: Any]
                        if resultError != nil {
                          let dataError = NSError.init(domain: "false", code: 404, userInfo: resultError)
                          callback(dataError, nil)
                        } else {
                          let data = json?["data"] as? [String: Any]
                          callback(nil, data)
                        }
                        break
                    case .failure(let error):
                      callback(error as NSError, nil)
                    }
                })
                break
            case .failure(let error):
              callback(error as NSError, nil)
            }
        })
    }
  
  // put
  class func put(url: String, parameters: Parameters?, callback: @escaping callback) {
    commonRequest(url: url, method: .put, parameters: parameters, encoding: JSONEncoding.default, callback: { (responseJSON) in
      switch responseJSON.result {
      case .success(let jsonData):
        let json = jsonData as? [String: Any]
        let resultError = json?["error"] as? [String: Any]
        if resultError != nil {
          let dataError = NSError.init(domain: "false", code: 404, userInfo: resultError)
          callback(dataError, nil)
        } else {
          let data = json?["data"] as? [String: Any]
          callback(nil, data)
        }
      case .failure(let error):
        callback(error as NSError, nil)
      }
    })
  }
  
  // download
    class func download(url: String, parameters: Parameters?, callback: @escaping callbackData) {
    
    let urlString: String = getUrl(url: url)
    let header = getHTTPHeader()
    Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseData { (response) in
      switch response.result {
      case .success(let data):
        callback(nil, data )
      case .failure(let error):
        callback(error as NSError?, nil)
      }
    }
  }
  
  class func downloadSync(url: String,destination:@escaping DownloadRequest.DownloadFileDestination) -> Alamofire.DefaultDownloadResponse {
    let urlString: String = getUrl(url: url)
    let header = getHTTPHeader()
    let response = Alamofire.download(urlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, to:destination).response()
    return response
  }
  
  // get Header
  private class func  getHTTPHeader() -> HTTPHeaders? {
    
    var header: HTTPHeaders = [:]
    return header
  }
  
  private class func getUrl(url: String) -> String {
    return "http://43.143.194.140:3000" + url
  }
}

