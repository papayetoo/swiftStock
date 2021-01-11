//
//  FlaskRequest.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/05.
//

import Foundation

struct FlaskRequest: Encodable{
    let code: String
    enum CodingKeys: String, CodingKey{
        case code
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
    }
}
