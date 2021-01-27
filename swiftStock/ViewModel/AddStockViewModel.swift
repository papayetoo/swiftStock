//
//  AddStockViewModel.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/27.
//

import Foundation
import CoreData

class AddStockViewModel {
    var stockInfoData : [StockInfo]?
    private let persistentManager = PersistenceManager.shared
    
    init?() {
        self.stockInfoData = self.fetchData()
    }
    
    func fetchData() -> [StockInfo]{
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockInfo")
        guard let data = self.persistentManager.fetch(request: request) as? [StockInfo] else {return []}
        return data
    }
}
