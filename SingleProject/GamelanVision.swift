//
//  GamelanVision.swift
//  TestCodeLACoreAPI
//
//  Created by yana mulyana on 01/10/19.
//  Copyright © 2019 yana mulyana. All rights reserved.
//

import Foundation
import UIKit
import LACoreNetwork

protocol VisionDelegate {
    func didCompleteDownloaded(data: Data)
    func progress(data: NSNumber)
}

public typealias Parameters = [String: Any]
public typealias Headers = [String: String]

class GamelanVision: NSObject {
    var controller: VisionDelegate!
    
    static let shared = GamelanVision()
    
    let visionMax: LACoreNetwork = {
       let configuration = URLSessionConfiguration.default
       configuration.timeoutIntervalForRequest = 40
       configuration.timeoutIntervalForResource = 40
       configuration.urlCache?.removeAllCachedResponses()
       configuration.requestCachePolicy = .reloadIgnoringCacheData
       configuration.urlCache = nil
       configuration.tlsMinimumSupportedProtocol = .tlsProtocol12
        
        let newSession = LACoreNetwork(configuration: configuration, delegate: visionPlayDelegate, queue: OperationQueue())
        newSession.gamelanAdapter = RequestInterceptor()
        return newSession
    }()
    
    fileprivate var defaultHeaders: [String:String] = [
        Key.HttpHeaders.contentType: Key.HttpHeaders.AppJson,
        Key.HttpHeaders.accept: Key.HttpHeaders.AppJson,
        Key.HttpHeaders.OSName: DeviceInformation.osName(),
        Key.HttpHeaders.OSVersion: DeviceInformation.osVersion()
    ]
    
    static let visionPlayDelegate = GamelanVisionLifeDelegate()
    
    override init() {
        super.init()
    }
    
    public func request<T: Codable>(url: String,
                           method: HttpMethod? = .Get,
                           encoding: JSONEncoding? = JSONEncoding.default,
                           headers: Headers? = nil,
                           parameters: Parameters? = nil,
                           completionHandler: @escaping (DataResponse<T>)->()) {
        
        var newHeaders: Headers = [:]
        if let headers = headers {
            newHeaders = headers.merging(self.defaultHeaders, uniquingKeysWith: { (_, newValue) in newValue })
        } else {
            newHeaders = self.defaultHeaders
        }
        
        self.visionMax.performRequest(url: url, method: method, encoding: encoding, headers: newHeaders, parameters: parameters) { (data, response, error) in
            var dataResponse = DataResponse<T>()
            
            if error != nil || data == nil {
                dataResponse.apiError = error
                dataResponse.result = .failure
                completionHandler(dataResponse)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            do {
                guard let data = data else { return }
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let object = try JSONDecoder().decode(T.self, from: data)
                dataResponse.result = .success
                dataResponse.urlResponse = response
                dataResponse.data = data
                dataResponse.object = object
                dataResponse.log = json
                completionHandler(dataResponse)
            } catch {
                dataResponse.apiError = NSError.ParsingError
                dataResponse.result = .failure
                completionHandler(dataResponse)
            }
        }
        
    }
    
    public func uploadFiles<T>(url: String,
                               headers: Headers? = nil,
                               parameters: Parameters? = nil,
                               data: Data,
                               completionHandler: @escaping (DataResponse<T>)->() ) where T : Codable {
        
        self.visionMax.performUpload(url: url, headers: headers, parameters: parameters, data: data) { (data, response, error) in
            var dataResponse = DataResponse<T>()

            if error != nil || data == nil {
                dataResponse.apiError = error
                dataResponse.result = .failure
                completionHandler(dataResponse)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                return
            }

            do {
                guard let data = data else { return }
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let object = try JSONDecoder().decode(T.self, from: data)
                dataResponse.result = .success
                dataResponse.urlResponse = response
                dataResponse.data = data
                dataResponse.object = object
                dataResponse.log = json
                completionHandler(dataResponse)
            } catch {
                dataResponse.apiError = NSError.ParsingError
                dataResponse.result = .failure
                completionHandler(dataResponse)
            }
        }
        
    }
    
    public func download(url: String, headers: Headers? = nil) {
        GamelanVision.visionPlayDelegate.visionDelegate = controller
        self.visionMax.performDownloadFile(url: url, headers: headers)
    }
    
    public func pause() {
        self.visionMax.pauseDownload()
    }
    
    public func resumeDownload() {
        self.visionMax.resumeDownload()
    }
    
}

class GamelanVisionLifeDelegate: SessionManagerDelegate {
    static let shared = GamelanVisionLifeDelegate()
    var visionDelegate: VisionDelegate!
    
    var data: Data? = Data()
    
    override init() {
        super.init()
        
        //URLSessionDelegate
        sessionDidReceiveChallengeWithCompletion = { session, authChallenge, completionHandler in
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        
        //URLSessionTaskDelegate
        didCompleteWithError = { session, task, error in
            print("didCompleteWithError \(String(describing: error))")
            guard let error = error else {
                // Handle success case.
                return
            }
            let userInfo = (error as NSError).userInfo
            if let resume = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                self.resumeData = resume
                self.data = resume
            }
        }
        
        //URLSessionDataDelegate
        didSendBodyData = { session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend in
            let _ : Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            //print("didSendBodyData \(total)")
        }
        
        //URLSessionDownloadDelegate
        downloadTaskDidResumeAtOffset = { session, downloadTask, fileOffset, expectedTotalBytes in
            let calculatedProgress = Float(fileOffset) / Float(expectedTotalBytes)
            DispatchQueue.main.async {
                print("progress resume \(NSNumber(value: calculatedProgress))")
            }
        }
        
        downloadTaskDidFinishDownloadingToURL = { session, downloadTask, location in
            print("didFinishDownloadingTo \(location)")
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent(location.lastPathComponent)
                try FileManager.default.moveItem(at: location, to: savedURL)
                let imageData = try Data(contentsOf: savedURL)
                DispatchQueue.main.async {
                    self.visionDelegate.didCompleteDownloaded(data: imageData)
                    print("imageData \(imageData)")
                }
                
                
            } catch {
                // handle filesystem error
            }
        }
        
        downloadTaskDidWriteData = { session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
            let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                self.visionDelegate.progress(data: NSNumber(value: calculatedProgress))
                //print("GamelanVisionLifeDelegate progress \(NSNumber(value: calculatedProgress))")
            }
        }
    }
    
}

class RequestInterceptor : GamelanAdapter {
    
    func adapter(_ urlRequest: URLRequest) throws -> URLRequest {
        let reachable = Reachability()?.isReachable ?? false
        
        if !reachable {
            throw NSError.NoInternet
        }
        
        return urlRequest
    }
}
