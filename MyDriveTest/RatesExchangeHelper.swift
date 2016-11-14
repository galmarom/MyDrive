//
//  RatesExchangeHelper.swift
//  MyDriveTest
//
//  Created by galmarom on 13/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit
import CoreData

/**The main data structure I made is a table (Dictionary) that represents the rates against the dollars, i.e - the amount of money one will get if he transferred his money to any supported currency.
 We can look at it like that:
 USD | EUR | GBP | CHF
 USD       1    |   0.9  | 0.8   |  0.85
 
 Or in words:
 If the conversion is from USD: I simply returns the value in the table: if one converts 1 USD to 1 EUR he gets 0.9 EUR.
 If the conversion is to USD: In order to calculate conversion between the USD in the EUR I calculate the reciprocal.
 If the conversion is from two currencies that are different from the USD I simply calculated the first currency value in USD (using the reciprocal) and convert it to the second currency using the  dictionary.
 */
class RateExchangeHelper: NSObject, NSFetchedResultsControllerDelegate {
    
    static let principalCurrency = "USD"
    static let sharedInstance = RateExchangeHelper()
    let exchangeRatesURL = "iOS-currency-exchange-rates/rates.json"

    // MARK - Core data methods
    var exchangeRatesWithMainCurrencyDictionary : [String : Float] = [RateExchangeHelper.principalCurrency : 1.0] //To<Rate>
    
    var managedObjectContext : NSManagedObjectContext {
        return CoreDataHelper.sharedInstance.managedObjectContext!
    }
    private var _fetchedResultsController: NSFetchedResultsController<ExchangeRateEntity>?
    
    var fetchedResultsController: NSFetchedResultsController<ExchangeRateEntity> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let fetchRequest = ExchangeRateEntity.fetchRequest() as NSFetchRequest<ExchangeRateEntity>
        let entity = NSEntityDescription.entity(forEntityName: fetchRequest.entityName!, in: managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "source", ascending: true),NSSortDescriptor(key: "target", ascending: true)]
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        _fetchedResultsController = fetchedResultsController
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            print("An error occured: \(error)")
        }
        return _fetchedResultsController!
    }
    
    // MARK: - Rate exchange helper methods
    func getExchangeRates(withCompletionHandler completionHandler:@escaping (Error?) -> Void){
        let sourceUrl = "\(NetworkHelper.sharedInstance.baseURL)/\(exchangeRatesURL)"
        NetworkHelper.sendRequest(url: sourceUrl, parameters: nil, withCompletionHandler: { data, response, error in
            if data != nil{
                do{
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                    if let itemsArray = parsedData["conversions"] as? [[String : AnyObject]] {
                        if itemsArray.count != 0{
                            itemsArray.forEach{
                                RateExchangeHelper.sharedInstance.createOrPopulateExchangeRateEntity(jsonDictionary: $0)
                            }
                            CoreDataHelper.sharedInstance.saveContext()
                        }else{
                            print("There are 0 entries at parsedData[\"summaries\"]")
                        }
                    }else{
                        print("Json doesn't contain an array of items under the value \"conversions\". parsedData = \(parsedData)")
                    }
                } catch let error as NSError {
                    print("An error has occured : " + error.localizedDescription)
                }
            }
            self.populateExchangeRateDictionary()
            completionHandler(error)
        })
    }
    
    func createOrPopulateExchangeRateEntity(jsonDictionary: [String : AnyObject]){
        var source =      jsonDictionary["from"] as? String
        var target =      jsonDictionary["to"] as? String
        var exchangeRate = jsonDictionary["rate"] as? Float
        guard (source != nil || target != nil || exchangeRate != nil) else {
            return
        }
        //The USD is the principal cuurency for comparison. If there neither the source nor the target equal to the princpal currency this json dictionary will be ignored.
        if  (source != RateExchangeHelper.principalCurrency && target != RateExchangeHelper.principalCurrency){
            return
        }
        //Swapping the target with the source if the target is the proncipal  currency in order to maintain the structure more coherent
        if(target == RateExchangeHelper.principalCurrency){
            target = source
            source = RateExchangeHelper.principalCurrency
            exchangeRate = 1.0 / exchangeRate!
        }
        
        //Checking if there is only one instance of the target currency
        let exchangeRateEntities = fetchedResultsController.fetchedObjects?.filter{
            return $0.target == target
        }
        if let count = exchangeRateEntities?.count, count > 1{
            print("ERROR: from: \(source) to: \(target) happened to appear twice in fetchedObjects")
        }
        //If a exchangeRateEntity exist it populates it with the new data , otherwise, a new one is created
        var exchangeRateEntity = exchangeRateEntities?.first
        if exchangeRateEntity == nil {
            let entity = self.fetchedResultsController.fetchRequest.entity!
            exchangeRateEntity = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: self.managedObjectContext) as? ExchangeRateEntity
            exchangeRateEntity?.source = source
            exchangeRateEntity?.target = target
            print("ExchangeRateEntity was added to core data: source:\(source) target:\(target) exchangeRate:\(exchangeRate)")
        }
        exchangeRateEntity?.exchangeRate = exchangeRate!
    }
    
    func populateExchangeRateDictionary(){
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("An error occured: \(error)")
        }
        self.fetchedResultsController.fetchedObjects?.forEach{
            //Generates the exchange rate within respect to the principal currency
            //note: this shouldn't happen as we swap the source and the target upon initialization. However, better safe then sorry
            if $0.source == RateExchangeHelper.principalCurrency{
                exchangeRatesWithMainCurrencyDictionary[$0.target!] = $0.exchangeRate
            }else if($0.target == RateExchangeHelper.principalCurrency){
                exchangeRatesWithMainCurrencyDictionary[$0.target!] = 1 / $0.exchangeRate
            }
        }
    }
    
    /**
     Returns the conversion result
     
     - parameter amount: Amount of money to convert
     - parameter source: The conversion's currency source
     - parameter target: The conversion's currency target
     */
    func convert(amount: Float, from source: String, to target: String) -> Float{
        return (amount * 1.0/exchangeRatesWithMainCurrencyDictionary[source]!) * exchangeRatesWithMainCurrencyDictionary[target]!
    }
    
    /**
     Deleting the given item from the core data
     */
    func removeItemFromCoreData(_ exchangeRateEntity: ExchangeRateEntity){
        self.managedObjectContext.delete(exchangeRateEntity)
        CoreDataHelper.sharedInstance.saveContext()
        self.populateExchangeRateDictionary()
    }
    
    
}
