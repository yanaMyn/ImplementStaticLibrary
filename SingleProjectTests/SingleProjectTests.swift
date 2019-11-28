//
//  SingleProjectTests.swift
//  SingleProjectTests
//
//  Created by yana mulyana on 16/10/19.
//  Copyright © 2019 LinkAja. All rights reserved.
//

import XCTest
import LACoreNetwork
@testable import SingleProject

class SingleProjectTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testParamHeader() {
        class EngineMock: DefaultRequest, Request {
            var gamelanAdapter: GamelanAdapter?
            
            fileprivate var sessionValue: URLSession = URLSession(configuration: .default)
            fileprivate var requestValue: NSMutableURLRequest = NSMutableURLRequest()
            fileprivate var dataTaskValue: URLSessionDataTask = URLSessionDataTask()
            
            public var statusCodeRange: [Int] {
                get {
                    return (200..<500).filter{$0 != 408}
                }
            }
            
            public var session: URLSession {
                get {
                    return self.sessionValue
                }
                set {
                    self.sessionValue = newValue
                }
            }
            
            public var request: NSMutableURLRequest {
                get {
                    return self.requestValue
                }
                set {
                    self.requestValue = newValue
                }
            }
            
            func encoding(urlString: String, aUrl: URL, encoding: JSONEncoding, parameters: Parameters?) {
                
            }
            
            public var dataTask: URLSessionDataTask {
                get {
                    return self.dataTaskValue
                }
                set {
                    self.dataTaskValue = newValue
                }
            }
            
            init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegate: URLSessionDelegate, queue: OperationQueue? = nil) {
                session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            }
            
            func performRequest(url: String, method: HttpMethod?, encoding: JSONEncoding?, headers: Headers?, parameters: Parameters?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                
                let data = (try! JSONSerialization.data(withJSONObject: headers!, options: .prettyPrinted))
                let url = URL(string: url)!
                let error: Error? = nil
                let urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: headers)
                guard let response = urlresponse, (self.statusCodeRange).contains(response.statusCode) else {
                    let error = NSError.Unknown
                    completionHandler(data, urlresponse, error)
                    return
                }
                completionHandler(data, urlresponse, error)
            }
            
            func cancelRequest() {
                self.dataTask.cancel()
            }
            
            
        }
        
        var mock: EngineMock?
        let mockLifeDelegate = MockLifeDelegate()
        
        mock = EngineMock(configuration: .default, delegate: mockLifeDelegate, queue: nil)
        let url = "https://fakerestapi.azurewebsites.net/api/User"
        
        let header = [
            "msisdn": "082128583134"
        ]
        
        mock?.performRequest(url: url, method: .Get, encoding: .default, headers: header, parameters: nil, completionHandler: { (data, response, error) in
            
            guard let _ = data, let resp = response else { return }
            let http = resp as! HTTPURLResponse
            XCTAssertEqual(http.allHeaderFields as! [String: String], header, "must equal")
            
        })
        
        
        class MockLifeDelegate: SessionManagerDelegate {
            
        }
    }
    
    func testEncodingQueryString() {
        class EngineMock: DefaultRequest, Request {
            var gamelanAdapter: GamelanAdapter?
            
            
            fileprivate var sessionValue: URLSession = URLSession(configuration: .default)
            fileprivate var requestValue: NSMutableURLRequest = NSMutableURLRequest()
            fileprivate var dataTaskValue: URLSessionDataTask = URLSessionDataTask()
            
            public var statusCodeRange: [Int] {
                get {
                    return (200..<500).filter{$0 != 408}
                }
            }
            
            public var session: URLSession {
                get {
                    return self.sessionValue
                }
                set {
                    self.sessionValue = newValue
                }
            }
            
            public var request: NSMutableURLRequest {
                get {
                    return self.requestValue
                }
                set {
                    self.requestValue = newValue
                }
            }
            
            func encoding(urlString: String, aUrl: URL, encoding: JSONEncoding, parameters: Parameters?) {
                switch encoding {
                case .default:
                    self.request.url = aUrl
                    if let parameters = parameters {
                        let httpBody = try? JSONSerialization.data(withJSONObject: parameters as Any, options: [])
                        request.httpBody = httpBody
                    }
                case .queryString:
                    guard let parameters = parameters else {
                        self.request.url = aUrl
                        return
                    }
                    
                    let urlComponents = NSURLComponents(string: urlString)
                    let aDict: [String: String] = parameters as! [String : String]
                    urlComponents?.queryItems = aDict.map { (key, value) in
                        URLQueryItem(name: key, value: value)
                    }
                    
                    self.request.url = urlComponents?.url
                }
            }
            
            public var dataTask: URLSessionDataTask {
                get {
                    return self.dataTaskValue
                }
                set {
                    self.dataTaskValue = newValue
                }
            }
            
            init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegate: URLSessionDelegate, queue: OperationQueue? = nil) {
                session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            }
            
            func performRequest(url: String, method: HttpMethod?, encoding: JSONEncoding?, headers: Headers?, parameters: Parameters?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                
                let data = "Hello world".data(using: .utf8)
                let aUrl = URL(string: url)!
                let error: Error? = nil
                self.encoding(urlString: url, aUrl: aUrl, encoding: encoding!, parameters: parameters)
                let urlresponse = HTTPURLResponse(url: self.request.url!, statusCode: 200, httpVersion:nil , headerFields: nil)
                guard let response = urlresponse, (self.statusCodeRange).contains(response.statusCode) else {
                    let error = NSError.Unknown
                    completionHandler(data, urlresponse, error)
                    return
                }
                completionHandler(data, urlresponse, error)
            }
            
            func cancelRequest() {
                self.dataTask.cancel()
            }
            
            
        }
        
        var mock: EngineMock?
        let mockLifeDelegate = MockLifeDelegate()
        
        mock = EngineMock(configuration: .default, delegate: mockLifeDelegate, queue: nil)
        let url = "https://fakerestapi.azurewebsites.net/api/User"
        
        let param = [
            "name": "dudung"
        ]
        
        mock?.performRequest(url: url, method: .Get, encoding: .queryString, headers: nil, parameters: param, completionHandler: { (data, response, error) in
            
            guard let _ = data, let resp = response else { return }
            
            let urlQueryStr = "https://fakerestapi.azurewebsites.net/api/User?name=dudung"
            
            XCTAssertEqual(urlQueryStr, resp.url?.absoluteString, "must equal")
            
        })
        
        
        class MockLifeDelegate: SessionManagerDelegate {
            
        }
    }
    
    func testServerNotValidData() {
        class EngineMock: DefaultRequest, Request {
            var gamelanAdapter: GamelanAdapter?
            
            
            fileprivate var sessionValue: URLSession = URLSession(configuration: .default)
            fileprivate var requestValue: NSMutableURLRequest = NSMutableURLRequest()
            fileprivate var dataTaskValue: URLSessionDataTask = URLSessionDataTask()
            
            public var statusCodeRange: [Int] {
                get {
                    return (200..<500).filter{$0 != 408}
                }
            }
            
            public var session: URLSession {
                get {
                    return self.sessionValue
                }
                set {
                    self.sessionValue = newValue
                }
            }
            
            public var request: NSMutableURLRequest {
                get {
                    return self.requestValue
                }
                set {
                    self.requestValue = newValue
                }
            }
            
            func encoding(urlString: String, aUrl: URL, encoding: JSONEncoding, parameters: Parameters?) {
                
            }
            
            public var dataTask: URLSessionDataTask {
                get {
                    return self.dataTaskValue
                }
                set {
                    self.dataTaskValue = newValue
                }
            }
            
            init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegate: URLSessionDelegate, queue: OperationQueue? = nil) {
                session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            }
            
            func performRequest(url: String, method: HttpMethod?, encoding: JSONEncoding?, headers: Headers?, parameters: Parameters?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                
                let employe = [
                    "id": "1"
                ]
                
                let data = (try! JSONSerialization.data(withJSONObject: employe, options: .prettyPrinted))
                
                let url = URL(string: url)!
                let error: Error? = nil
                let urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                guard let response = urlresponse, (self.statusCodeRange).contains(response.statusCode) else {
                    let error = NSError.Unknown
                    completionHandler(data, urlresponse, error)
                    return
                }
                completionHandler(data, urlresponse, error)
            }
            
            func cancelRequest() {
                self.dataTask.cancel()
            }
            
            
        }
        
        var mock: EngineMock?
        let mockLifeDelegate = MockLifeDelegate()
        
        mock = EngineMock(configuration: .default, delegate: mockLifeDelegate, queue: nil)
        let url = "http://159.89.205.7:7008/v1.0/notification/notify"
        
        mock?.performRequest(url: url, method: .Get, encoding: .default, headers: nil, parameters: nil, completionHandler: { (data, response, error) in
            
            do {
                guard let data = data else { return }
                let object = try JSONDecoder().decode([String: String].self, from: data)
                
                let employe = ["id": "1",
                               "employee_name": "dodong",
                               "employee_salary": "750000",
                               "employee_age": "23"]
                
                XCTAssertNotEqual(object, employe, "valid")
            } catch {
                
            }
            
        })
        
        
        class MockLifeDelegate: SessionManagerDelegate {
            
        }
    }
    
    func testServerNoWrongDataResponseValid(){
        class EngineMock: DefaultRequest, Request {
            var gamelanAdapter: GamelanAdapter?
            
            
            fileprivate var sessionValue: URLSession = URLSession(configuration: .default)
            fileprivate var requestValue: NSMutableURLRequest = NSMutableURLRequest()
            fileprivate var dataTaskValue: URLSessionDataTask = URLSessionDataTask()
            
            public var statusCodeRange: [Int] {
                get {
                    return (200..<500).filter{$0 != 408}
                }
            }
            
            public var session: URLSession {
                get {
                    return self.sessionValue
                }
                set {
                    self.sessionValue = newValue
                }
            }
            
            public var request: NSMutableURLRequest {
                get {
                    return self.requestValue
                }
                set {
                    self.requestValue = newValue
                }
            }
            
            func encoding(urlString: String, aUrl: URL, encoding: JSONEncoding, parameters: Parameters?) {
                
            }
            
            public var dataTask: URLSessionDataTask {
                get {
                    return self.dataTaskValue
                }
                set {
                    self.dataTaskValue = newValue
                }
            }
            
            init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegate: URLSessionDelegate, queue: OperationQueue? = nil) {
                session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            }
            
            func performRequest(url: String, method: HttpMethod?, encoding: JSONEncoding?, headers: Headers?, parameters: Parameters?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                
                var arrayEmployees = [[String: String]]()
                let employe = [
                    "id": "1",
                    "employee_name": "dodong",
                    "employee_salary": "750000",
                    "employee_age": "23"
                ]
                
                let employe2 = [
                    "id": "2",
                    "employee_name": "didong",
                    "employee_salary": "750000",
                    "employee_age": "23"
                ]
                
                arrayEmployees.append(employe)
                arrayEmployees.append(employe2)
                
                let data = (try! JSONSerialization.data(withJSONObject: arrayEmployees, options: .prettyPrinted))
                let url = URL(string: url)!
                let error: Error? = nil
                let urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                guard let response = urlresponse, (self.statusCodeRange).contains(response.statusCode) else {
                    let error = NSError.Unknown
                    completionHandler(data, urlresponse, error)
                    return
                }
                completionHandler(data, urlresponse, error)
            }
            
            func cancelRequest() {
                self.dataTask.cancel()
            }
            
            
        }
        
        var mock: EngineMock?
        let mockLifeDelegate = MockLifeDelegate()
        
        mock = EngineMock(configuration: .default, delegate: mockLifeDelegate, queue: nil)
        let url = "http://159.89.205.7:7008/v1.0/notification/notify"
        
        mock?.performRequest(url: url, method: .Get, encoding: .default, headers: nil, parameters: nil, completionHandler: { (data, response, error) in
            
            do {
                guard let data = data else { return }
                let object = try JSONDecoder().decode([[String: String]].self, from: data)
                
                XCTAssertTrue(object.count > 0, "have data")
                XCTAssertTrue(object[0]["employee_name"] == "dodong", "same name")
                
            } catch {
                
            }
            
        })
        
        
        class MockLifeDelegate: SessionManagerDelegate {
            
        }
    }
    
    func testServerEmptyArrayData() {
        class EngineMock: DefaultRequest, Request {
            var gamelanAdapter: GamelanAdapter?
            
            
            fileprivate var sessionValue: URLSession = URLSession(configuration: .default)
            fileprivate var requestValue: NSMutableURLRequest = NSMutableURLRequest()
            fileprivate var dataTaskValue: URLSessionDataTask = URLSessionDataTask()
            
            public var statusCodeRange: [Int] {
                get {
                    return (200..<500).filter{$0 != 408}
                }
            }
            
            public var session: URLSession {
                get {
                    return self.sessionValue
                }
                set {
                    self.sessionValue = newValue
                }
            }
            
            public var request: NSMutableURLRequest {
                get {
                    return self.requestValue
                }
                set {
                    self.requestValue = newValue
                }
            }
            
            func encoding(urlString: String, aUrl: URL, encoding: JSONEncoding, parameters: Parameters?) {
                
            }
            
            public var dataTask: URLSessionDataTask {
                get {
                    return self.dataTaskValue
                }
                set {
                    self.dataTaskValue = newValue
                }
            }
            
            init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegate: URLSessionDelegate, queue: OperationQueue? = nil) {
                session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            }
            
            func performRequest(url: String, method: HttpMethod?, encoding: JSONEncoding?, headers: Headers?, parameters: Parameters?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                
                let emptyArray: [String] = [String]()
                let data = (try! JSONSerialization.data(withJSONObject: emptyArray, options: .prettyPrinted))
                let url = URL(string: url)!
                let error: Error? = nil
                let urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                guard let response = urlresponse, (self.statusCodeRange).contains(response.statusCode) else {
                    let error = NSError.Unknown
                    completionHandler(data, urlresponse, error)
                    return
                }
                completionHandler(data, urlresponse, error)
            }
            
            func cancelRequest() {
                self.dataTask.cancel()
            }
            
            
        }
        
        var mock: EngineMock?
        let mockLifeDelegate = MockLifeDelegate()
        
        mock = EngineMock(configuration: .default, delegate: mockLifeDelegate, queue: nil)
        let url = "http://159.89.205.7:7008/v1.0/notification/notify"
        
        mock?.performRequest(url: url, method: .Get, encoding: .default, headers: nil, parameters: nil, completionHandler: { (data, response, error) in
            
            do {
                guard let data = data else { return }
                let object = try JSONDecoder().decode([String].self, from: data)
                XCTAssertEqual(object.count, 0, "object must empty")
            } catch {
                
            }
            
        })
        
        
        class MockLifeDelegate: SessionManagerDelegate {
            
        }
    }
    
    func testServerNilData() {
        class EngineMock: DefaultRequest, Request {
            var gamelanAdapter: GamelanAdapter?
            
            
            fileprivate var sessionValue: URLSession = URLSession(configuration: .default)
            fileprivate var requestValue: NSMutableURLRequest = NSMutableURLRequest()
            fileprivate var dataTaskValue: URLSessionDataTask = URLSessionDataTask()
            
            public var statusCodeRange: [Int] {
                get {
                    return (200..<500).filter{$0 != 408}
                }
            }
            
            public var session: URLSession {
                get {
                    return self.sessionValue
                }
                set {
                    self.sessionValue = newValue
                }
            }
            
            public var request: NSMutableURLRequest {
                get {
                    return self.requestValue
                }
                set {
                    self.requestValue = newValue
                }
            }
            
            func encoding(urlString: String, aUrl: URL, encoding: JSONEncoding, parameters: Parameters?) {
                
            }
            
            public var dataTask: URLSessionDataTask {
                get {
                    return self.dataTaskValue
                }
                set {
                    self.dataTaskValue = newValue
                }
            }
            
            init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegate: URLSessionDelegate, queue: OperationQueue? = nil) {
                session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            }
            
            func performRequest(url: String, method: HttpMethod?, encoding: JSONEncoding?, headers: Headers?, parameters: Parameters?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                
                let data: Data? = nil
                let url = URL(string: url)!
                let error: Error? = nil
                let urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                guard let response = urlresponse, (self.statusCodeRange).contains(response.statusCode) else {
                    let error = NSError.Unknown
                    completionHandler(data, urlresponse, error)
                    return
                }
                completionHandler(data, urlresponse, error)
            }
            
            func cancelRequest() {
                self.dataTask.cancel()
            }
            
            
        }
        
        var mock: EngineMock?
        let mockLifeDelegate = MockLifeDelegate()
        
        mock = EngineMock(configuration: .default, delegate: mockLifeDelegate, queue: nil)
        let url = "http://159.89.205.7:7008/v1.0/notification/notify"
        
        mock?.performRequest(url: url, method: .Get, encoding: .default, headers: nil, parameters: nil, completionHandler: { (data, response, error) in
            XCTAssertNil(data, "data must nil")
        })
        
        
        class MockLifeDelegate: SessionManagerDelegate {
            
        }
    }

}
