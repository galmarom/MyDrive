//
//  ExchangeRate+CoreDataProperties.swift
//  MyDriveTest
//
//  Created by galmarom on 11/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ExchangeRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeRate> {
        return NSFetchRequest<ExchangeRate>(entityName: "ExchangeRate");
    }

    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var convertionRate: Float

}
