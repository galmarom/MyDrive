//
//  ExchangeRateEntity+CoreDataProperties.swift
//  MyDriveTest
//
//  Created by galmarom on 13/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import Foundation
import CoreData


extension ExchangeRateEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeRateEntity> {
        return NSFetchRequest<ExchangeRateEntity>(entityName: "ExchangeRateEntity");
    }

    @NSManaged public var target: String?
    @NSManaged public var exchangeRate: Float
    @NSManaged public var source: String?

    override public var debugDescription: String{
        return "ExchangeRateEntity: source: \(source), target: \(target), exchangeRate: \(exchangeRate)"
    }
}
