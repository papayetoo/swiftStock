//
//  StockData.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/04.
//

import Foundation

struct StockData: Codable {
    var openPrice : [Double]
    var closePrice : [Double]
    var highPrice : [Double]
    var lowPrice : [Double]
    var volume: [Int]
}
