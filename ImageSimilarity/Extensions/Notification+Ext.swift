//
//  Notification+Ext.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 8.10.2022.
//

import Foundation

extension Notification.Name {
    static let imageURLs = Notification.Name("imageURLs")
    static let indexes = Notification.Name("indexes")
}

extension NotificationCenter {
    func send(_ name:Notification.Name,_ data:Any? = nil) {
        var userInfo: [String:Any]?
        
        if let data = data {
            userInfo = [String:Any]()
            userInfo?["data"] = data
        }
        
        NotificationCenter.default.post(name: name, object: nil,userInfo: userInfo)
    }
}
