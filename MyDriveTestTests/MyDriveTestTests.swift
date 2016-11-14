//
//  MyDriveTestTests.swift
//  MyDriveTestTests
//
//  Created by galmarom on 11/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import XCTest
@testable import MyDriveTest

class MyDriveTestTests: XCTestCase {
    
    var rateExchangeDictionary : [String : Float]  {
        return RateExchangeHelper.sharedInstance.exchangeRatesWithMainCurrencyDictionary
    }
    var fakeJsonDic1 : [String:AnyObject] = ["from": "USD" as AnyObject,"to": "CUR1" as AnyObject,"rate": Float(3) as AnyObject]
    let fakeJsonDic2 : [String:AnyObject]  = ["from": "CUR2" as AnyObject,"to": "USD" as AnyObject,"rate": Float(0.5) as AnyObject]
    let jsonWithErrorDic1 : [String:AnyObject]  = ["fake": "USD" as AnyObject,"to": "CUR3" as AnyObject,"rate":Float(0.5) as AnyObject]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddRatesCorrectly(){
        XCTAssertTrue(rateExchangeDictionary["USD"] == 1,"Exchange rate dictionary has to have an entry for USD that is equal to 1")
        createEntityAndPopulateDictionary(fakeJsonDic1)
        XCTAssertTrue(rateExchangeDictionary["CUR1"] == 3,"Json isn't inserted correctly into the dictionary")
        createEntityAndPopulateDictionary(fakeJsonDic2)
        XCTAssertTrue(rateExchangeDictionary["CUR2"] == 2,"Json isn't inserted correctly into the dictionary")
        createEntityAndPopulateDictionary(jsonWithErrorDic1)
        XCTAssertNil(rateExchangeDictionary["CUR3"])
        XCTAssertTrue(rateExchangeDictionary["CUR2"] == 2,"Json isn't inserted correctly into the dictionary")
        fakeJsonDic1["rate"] = Float(0.7) as AnyObject
        createEntityAndPopulateDictionary(fakeJsonDic1)
        XCTAssertTrue(rateExchangeDictionary["CUR1"] == 0.7,"Json isn't inserted correctly into the dictionary")
    }
    
    func testConversion(){
        var tempAmount : Float = RateExchangeHelper.sharedInstance.convert(amount: 100, from: "USD", to: "USD")
        var expectedResult : Float = 100
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")
        
        createEntityAndPopulateDictionary(fakeJsonDic1)
        tempAmount = RateExchangeHelper.sharedInstance.convert(amount: 9, from: "USD", to: "CUR1")
        expectedResult = 27
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")
        tempAmount = RateExchangeHelper.sharedInstance.convert(amount: 3, from: "CUR1", to: "USD")
        expectedResult = 1
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")
        
        createEntityAndPopulateDictionary(fakeJsonDic2)
        tempAmount = RateExchangeHelper.sharedInstance.convert(amount: 100, from: "USD", to: "CUR2")
        expectedResult = 200
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")
        tempAmount = RateExchangeHelper.sharedInstance.convert(amount: 100, from: "CUR2", to: "USD")
        expectedResult = 50
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")

        tempAmount = RateExchangeHelper.sharedInstance.convert(amount: 3, from: "CUR1", to: "CUR2")
        expectedResult = 2
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")
        tempAmount = RateExchangeHelper.sharedInstance.convert(amount: 2, from: "CUR2", to: "CUR1")
        expectedResult = 3
        XCTAssertTrue(tempAmount == expectedResult,"Error in conversion test. The result was \(tempAmount) instead \(expectedResult)")
    }

    
    private func createEntityAndPopulateDictionary(_ jsonDictionary:[String : AnyObject]){
        RateExchangeHelper.sharedInstance.createOrPopulateExchangeRateEntity(jsonDictionary:jsonDictionary)
        RateExchangeHelper.sharedInstance.populateExchangeRateDictionary()
    }
    
}
