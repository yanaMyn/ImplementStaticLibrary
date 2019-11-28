//
//  User.swift
//  SingleProject
//
//  Created by yana mulyana on 16/10/19.
//  Copyright © 2019 LinkAja. All rights reserved.
//

import Foundation

struct User: Codable {
    let ID: Int
    let UserName: String
    let Password: String
}

struct PushStatus: Codable {
    let pushStatus: String
}
