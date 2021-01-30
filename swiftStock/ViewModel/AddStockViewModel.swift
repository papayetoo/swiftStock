//
//  AddStockViewModel.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/27.
//

import Foundation
import CoreData

struct AddStockViewModel {
    typealias Listener = ([StockInfo]?) -> Void
    var listener: Listener?
    var stockInfoData: [StockInfo]? {
        didSet {
            listener?(stockInfoData)
        }
    }
    private let persistentManager = PersistenceManager.shared

    init?() {
        self.stockInfoData = self.fetchData()
    }

    func fetchData() -> [StockInfo] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockInfo")
        guard let data = self.persistentManager.fetch(request: request) as? [StockInfo] else {return []}
        return data
    }

    mutating func bind(listener: Listener?) {
        self.listener = listener
    }
}
