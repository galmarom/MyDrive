//
//  CurrencyExchangeViewController.swift
//  MyDriveTest
//
//  Created by galmarom on 11/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit


class CurrencyExchangeViewController: UIViewController , UIPickerViewDelegate,UIPickerViewDataSource {
    
    //UI elements
    @IBOutlet weak var sourcePickerView: UIPickerView!
    @IBOutlet weak var targetPickerView: UIPickerView!
    @IBOutlet weak var convertionAmountTextField: UITextField!
    @IBOutlet weak var convertionResultLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView?
    
    //Local variables
    private var currencies = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateExchangeRatesArray()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateExchangeRatesArray(){
        self.animateActivityIndicator(start: true)
        weak var weakSelf = self
        RateExchangeHelper.sharedInstance.getExchangeRates(withCompletionHandler: { error in
            if(error != nil){
                //Presents an error alert
                let alert = UIAlertController(title: "Error", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style:.cancel, handler: { action in
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).asyncAfter(deadline: .now() + .seconds(5)){
                        weakSelf?.populateExchangeRatesArray()
                    }
                })
                alert.addAction(OKAction)
                DispatchQueue.main.async{
                    weakSelf?.present(alert, animated: true, completion: nil)
                }
                //Will try to retrieve the items again after 5 seconds
                return
            }else{
                //Store locally and sort the currencies in order to maintain a more approachable DS for the UIPickers
                weakSelf?.currencies = RateExchangeHelper.sharedInstance.exchangeRatesWithMainCurrencyDictionary.keys.sorted{
                    return $0 < $1
                }
                DispatchQueue.main.async{
                    weakSelf?.reloadView()
                }
            }
            weakSelf?.animateActivityIndicator(start: false)
        })
    }
    
    private func reloadView(){
        self.sourcePickerView.reloadAllComponents()
        self.targetPickerView.reloadAllComponents()
    }
    
    //MARK: UIPickerViewDataSource methods
    func numberOfComponents(in: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    //MARK: UIPickerViewDelegate methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let amount = Float(self.convertionAmountTextField.text!){
            let selectedSource = currencies[sourcePickerView.selectedRow(inComponent: 0)]
            let selectedTarget = currencies[targetPickerView.selectedRow(inComponent: 0)]
            self.convertionResultLabel.text =
                String(RateExchangeHelper.sharedInstance.convert(amount: amount, from: selectedSource, to: selectedTarget))
        }
    }

    
    //Start or Stops activity loader on the UI(main) thread
    private func animateActivityIndicator(start:Bool){
        if self.activityIndicator == nil{
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.activityIndicator!.color = UIColor.init(colorLiteralRed: 0.91, green: 0.82, blue: 0.86, alpha: 1)
            self.activityIndicator!.hidesWhenStopped = true
            self.activityIndicator!.center = self.view!.center
            self.view.addSubview(self.activityIndicator!)
        }
        DispatchQueue.main.async {
            self.view.bringSubview(toFront: self.activityIndicator!)
            self.activityIndicator!.isHidden = !start
            if start{
                self.activityIndicator!.startAnimating()
            }else{
                self.activityIndicator!.stopAnimating()
            }
        }
    }
    
    
}

