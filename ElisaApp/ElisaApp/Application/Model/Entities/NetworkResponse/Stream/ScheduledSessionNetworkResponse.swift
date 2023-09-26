//
//  ScheduledSessionNetworkResponse.swift
//  ElisaApp
//
//  Created by alexandr galkin on 13.07.2022.
//

import Foundation

struct ScheduledSessionNetworkResponse: Decodable {
    var session: ScheduledSessionNetworkResponse.Session?
    
    struct Session: Decodable {
        var facebookId: String
        var campaignId: String
        var instance: Instance
        
        struct Instance: Decodable {
            var ipv4: String?
        }
    }
}
