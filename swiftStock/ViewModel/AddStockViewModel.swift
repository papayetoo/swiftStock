//
//  AddStockViewModel.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/27.
//

import Foundation
import CoreData

struct AddStockViewModel {

    var stockInfoData: [StockInfo]?
    var stockInfoDynamic: Dynamic<[StockInfo]>?
    private let persistentManager = PersistenceManager.shared

    init?() {
        self.fetchData()
    }

    mutating func fetchData() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockInfo")
        request.predicate = NSPredicate(format: "star = %@", NSNumber(booleanLiteral: false))
        guard let data = self.persistentManager.fetch(request: request) as? [StockInfo] else {return}
        self.stockInfoData = data
    }

}

class Dynamic<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?

    func bind(_ listener: Listener?) {
        self.listener = listener
    }

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ v: T) {
        self.value = v
    }
}
