//
//  IceCandidateEvent.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 24.03.2022.
//

struct IceCandidateEvent: Decodable {
    let candidate: String
    let sdpMLineIndex: Int
    let sdpMid: String
}
