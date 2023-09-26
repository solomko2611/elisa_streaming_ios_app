//
//  PageListResponse.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 10.03.2022.
//

import Foundation

struct PageListResponse: Decodable {
    let items: [Page]
    let backendURL: String
}

struct Page: Decodable, Hashable, Equatable {
    
    private enum CodingKeys: String, CodingKey {
        case id, name, campaigns
    }
    
    let id: String
    let name: String
    let campaigns: Campaigns?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        campaigns = try? container.decode(Campaigns.self, forKey: .campaigns)
    }
}

struct Campaigns: Decodable, Hashable {
    let items: [Campaign]
}

struct Campaign: Decodable, Hashable {
    let hostOverlayURL: String
    let id: String
    let name: String
    let startTime: Int?
    let resolution: String?
    let streamProtocol:String?
    let aVCaptureVideoStabilizationMode: Int
    let codec: String
    
    private enum CodingKeys : String, CodingKey {
        case hostOverlayURL,id, name, startTime, resolution, streamProtocol = "protocol", aVCaptureVideoStabilizationMode, codec
    }
}
