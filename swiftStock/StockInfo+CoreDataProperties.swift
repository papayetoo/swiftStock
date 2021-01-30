//
//  StockInfo+CoreDataProperties.swift
//  
//
//  Created by 최광현 on 2021/01/19.
//
//

import Foundation
import CoreData

extension StockInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockInfo> {
        return NSFetchRequest<StockInfo>(entityName: "StockInfo")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?

}
