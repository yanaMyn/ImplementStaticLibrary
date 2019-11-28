//
//  DataResponse.swift
//  SingleProject
//
//  Created by yana mulyana on 16/10/19.
//  Copyright © 2019 LinkAja. All rights reserved.
//

import Foundation

public enum ResultType {
    case success
    case failure
}

public struct DataResponse<T> {
    
    public var urlResponse: HTTPURLResponse?
    public var data: Data?
    public var object: T?
    public var apiError: Error?
    public var result: ResultType?
    public var log: Any?
    
    public init(urlResponse: HTTPURLResponse? = nil, data: Data? = nil, object: T? = nil, apiError: Error? = nil, result: ResultType? = nil, log: Any? = nil) {
        self.urlResponse = urlResponse
        self.data = data
        self.object = T.self as? T
        self.apiError = apiError
        self.result = result
        self.log = log
    }
    
}

struct Object<T: Codable>: Codable {
    let message: String?
    let status: String?
    let metadata: Metadata?
    let data: T?
}

struct Metadata: Codable {
    let page: Int?
    let total_page: Int?
    let limit: Int?
}
