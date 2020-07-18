//
//  FilterViewController.swift
//  CicekSepeti
//
//  Created by RECEP CAN BABAOGLU on 18.07.2020.
//  Copyright © 2020 Can Babaoğlu. All rights reserved.
//

import UIKit
import Alamofire

protocol sendFilterDelegateProtocol {
    func sendDataToFirstViewController(parameters: [String : String])
}

class FilterViewController: UIViewController {
    
    var delegate: sendFilterDelegateProtocol? = nil
    
    var dynamicFilterArray: [DynamicFilterObject] = []
    
    @IBOutlet var listButton: UIButton!
    @IBOutlet var filterView: UIView!

    @IBOutlet var categoryView: UIView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryButton1: UIButton!
    @IBOutlet var categoryButton2: UIButton!
    @IBOutlet var categoryButton3: UIButton!
    
    var categoryButtonArray: [UIButton] = []
    var params: [String : String] = ["":""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getFilterRequest()
    }
    
 // MARK: setupUI
    func setupUI(){
        filterView.layer.cornerRadius = 16
        listButton.layer.cornerRadius = 16
        listButton.layer.shadowColor = #colorLiteral(red: 0.7843137255, green: 0.5882352941, blue: 0.7843137255, alpha: 1)
        listButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        listButton.layer.shadowOpacity = 0.8
        listButton.layer.shadowRadius = 16
        listButton.layer.masksToBounds = false
        
    }
    
// MARK: setupDynamicUI
    func setupDynamicUI(){
           
        categoryView.layer.cornerRadius = 16
        categoryView.layer.borderWidth = 1.0
        categoryView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        categoryLabel.text = dynamicFilterArray[0].name!
        categoryButtonArray.append(categoryButton1)
        categoryButtonArray.append(categoryButton2)
        categoryButtonArray.append(categoryButton3)
        
        for k in 0..<3{
            categoryButtonArray[k].setTitle(dynamicFilterArray[0].filterValues[k].name, for: .normal)
        }
        
       }
    
 // MARK: Send filters to FirstVC
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        
        if self.delegate != nil {
            checkCategoryFilters()
            self.delegate?.sendDataToFirstViewController(parameters: params)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func checkCategoryFilters(){
        
        var returnNSNumber: NSNumber!
        for k in 0..<3{
            if(categoryButtonArray[k].isSelected == true){
                returnNSNumber = dynamicFilterArray[0].filterValues[k].id
                break
            }
        }
        
        let detailId = String(String(format:"%f", returnNSNumber!.doubleValue).prefix(7))
        
        //groupID kontrolü yapabiliriz 1 ise detailList olacak param
       // params = ["detailList":detailId]
        params["detailList"] = detailId
      //  params["detailList"] = "2009383"
    }
    
    
// MARK: Category button actions
    @IBAction func categoryButton1Pressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categoryButton2.isSelected = false
        categoryButton3.isSelected = false
    }
    
    @IBAction func categoryButton2Pressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categoryButton1.isSelected = false
        categoryButton3.isSelected = false
    }
    
    @IBAction func categoryButton3Pressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categoryButton1.isSelected = false
        categoryButton2.isSelected = false
    }
    
    
    
    
// MARK: Filter request & parsing
    
    func getFilterRequest(){
        
        let reqUrl = requestUrl.productList.rawValue
        Alamofire.request(reqUrl, method: .get).responseJSON { response in
            
               if (response.result.isSuccess){
                   self.JSONParser(requestResponse: response.result.value as! NSDictionary)
               }else {
                   print("Error: \(String(describing: response.result.error))")
               }
           // self.tableView.reloadData()
           }
       }
    
    
    func JSONParser(requestResponse: NSDictionary){
                           
        let responseResult: NSDictionary = requestResponse.object(forKey: "result") as! NSDictionary
        let resultData: NSDictionary = responseResult.object(forKey: "data") as! NSDictionary
        let dataFilters: NSDictionary = resultData.object(forKey: "mainFilter") as! NSDictionary
        let dynamicFilter: NSArray = dataFilters.object(forKey: "dynamicFilter") as! NSArray

        self.dynamicFilterArray.removeAll()
        
            for i in 0..<dynamicFilter.count{
                
                let tempFilter = DynamicFilterObject()
              //  tempFilter.filterValues = [DynamicFilterValuesObject]()
                
                tempFilter.name = ((dynamicFilter[i] as AnyObject).object(forKey: "name") as! String)
                tempFilter.detailId = ((dynamicFilter[i] as AnyObject).object(forKey: "detailId") as! NSNumber)
                let filterValuesArray = ((dynamicFilter[i] as AnyObject).object(forKey: "values") as! NSArray)
                
                for j in 0..<filterValuesArray.count{
                    
                    let filterValues = DynamicFilterValuesObject()
                    filterValues.name = ((filterValuesArray[j] as AnyObject).object(forKey: "name") as! String)
                    filterValues.id = ((filterValuesArray[j] as AnyObject).object(forKey: "id") as! NSNumber)
                    filterValues.group = ((filterValuesArray[j] as AnyObject).object(forKey: "group") as! NSNumber)
                    tempFilter.filterValues.append(filterValues)
                }
                self.dynamicFilterArray.append(tempFilter)
               }
        
        if(dynamicFilterArray[0].name != nil){
            setupDynamicUI()
        }
        
        
       }
}
