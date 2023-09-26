//
//  IceServersResponse.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 24.03.2022.
//

struct IceServersResponse: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case iceServers, stun, turn
    }
    
    let stun: [String]
    let turn: [IceServer]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let iceServers = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .iceServers)
        stun = try iceServers.decode([String].self, forKey: .stun)
        turn = try iceServers.decode([IceServer].self, forKey: .turn)
    }
}
