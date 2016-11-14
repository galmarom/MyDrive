//
//  CoreDataHelperTests.swift
//  MyDriveTest
//
//  Created by galmarom on 13/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import XCTest
@testable import MyDriveTest

class CoreDataHelperTests: XCTestCase {
    
    let fakeJsonDic1 : [String:AnyObject] = ["from": "USD" as AnyObject,"to": "ABC" as AnyObject,"rate": Float(0.66) as AnyObject]
    
    lazy var coreDataHelper : CoreDataHelper = {
        return CoreDataHelper.sharedInstance  //Initilize the CoreDataHelper singleton and the lazy loaders
    }()


    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCheckCoreDataSetup(){
        XCTAssertNotNil(coreDataHelper.managedObjectModel,"managedObjectModel shouldn't be nil")
        XCTAssertNotNil(coreDataHelper.persistentStoreCoordinator,"persistentStoreCoordinator shouldn't be nil")
        XCTAssertNotNil(coreDataHelper.managedObjectContext,"managedOmanagedObjectContextbjectModel shouldn't be nil")
    }

    //Create an object with the fake dictionary and checks whether it created and delted properly
    func testSaveAndFlushCoreData(){
        RateExchangeHelper.sharedInstance.createOrPopulateExchangeRateEntity(jsonDictionary:fakeJsonDic1)
        RateExchangeHelper.sharedInstance.populateExchangeRateDictionary()
        let abcEntity = RateExchangeHelper.sharedInstance.fetchedResultsController.fetchedObjects?.filter{
            $0.target == "ABC"
        }
        XCTAssertTrue(abcEntity?.count == 1,"Core data failed to store the given property. The number of the entities found is \(abcEntity?.count)")
        XCTAssertNotNil(abcEntity?.first,"Core data doesn't store the entity properly")
        if let abcEntity = abcEntity?.first {
            RateExchangeHelper.sharedInstance.removeItemFromCoreData(abcEntity)
            let abcEntityAfterDeletion = RateExchangeHelper.sharedInstance.fetchedResultsController.fetchedObjects?.filter{
                $0.target == "ABC"
            }
            XCTAssertTrue(abcEntityAfterDeletion?.count == 0,"Core data failed to delete the given property. The number of the entities found is \(abcEntityAfterDeletion?.count)")
            XCTAssertNil(abcEntityAfterDeletion?.first,"Core data doesn't delete the entity properly")
        }
    }

}
