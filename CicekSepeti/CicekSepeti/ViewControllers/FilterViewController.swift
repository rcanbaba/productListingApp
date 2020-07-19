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
    func sendDataToFirstViewController(parameters: String)
}

//typealias MutipleValue = (firstObject: String, secondObject: String)

class FilterViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var delegate: sendFilterDelegateProtocol? = nil
    
    var dynamicFilterArray: [DynamicFilterObject] = []
    
    @IBOutlet var listButton: UIButton!
    @IBOutlet var filterView: UIView!

    @IBOutlet var categoryView: UIView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryButton1: UIButton!
    @IBOutlet var categoryButton2: UIButton!
    @IBOutlet var categoryButton3: UIButton!
    
    @IBOutlet var personView: UIView!
    @IBOutlet var personButton: UIButton!
    @IBOutlet var personLabel: UILabel!
    
    @IBOutlet var productGroupView: UIView!
    @IBOutlet var productGroupLabel: UILabel!
    
    var categoryButtonArray: [UIButton] = []
    var params: String = ""
    var selectedIndex: Int = -1
        
    let cellReuseIdentifier = "cell"
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFilterRequest()
        setupUI()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
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
        personView.layer.cornerRadius = 16
        personView.layer.borderWidth = 1.0
        personView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        productGroupView.layer.cornerRadius = 16
        productGroupView.layer.borderWidth = 1.0
        productGroupView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.layer.cornerRadius = 16
        
        categoryLabel.text = dynamicFilterArray[0].name!
        categoryButtonArray.append(categoryButton1)
        categoryButtonArray.append(categoryButton2)
        categoryButtonArray.append(categoryButton3)
        
        for k in 0..<3{
            categoryButtonArray[k].setTitle(dynamicFilterArray[0].filterValues[k].name, for: .normal)
        }
        personLabel.text = dynamicFilterArray[1].name!
        personButton.setTitle(dynamicFilterArray[1].filterValues[0].name, for: .normal)
        productGroupLabel.text = dynamicFilterArray[2].name!

       }
    
 // MARK: Send filters to FirstVC
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        
        if self.delegate != nil {
            checkFilters()
            self.delegate?.sendDataToFirstViewController(parameters: params)
            dismiss(animated: true, completion: nil)
        }
    }
    
 // MARK: check Filters
    func checkFilters(){
 // TO DO: groupID kontrolü yapabiliriz 1 ise detailList olacak param ama gerek yok kategoriler hep 1 geliyor..
    //Kategori
        var returnNSNumber: NSNumber!
        for k in 0..<3{
            if(categoryButtonArray[k].isSelected == true){
                returnNSNumber = dynamicFilterArray[0].filterValues[k].id
                let detailId = String(String(format:"%f", returnNSNumber!.doubleValue).prefix(7))
                params = "detailList=" + detailId
                break
            }
        }
    //Kişiselleştirme
        if(personButton.isSelected == true){
            if(dynamicFilterArray[1].filterValues[0].name == "Kişiselleştirilmiş" ){
                
                let personFilterIdNS = dynamicFilterArray[1].filterValues[0].id
                let personFilterId = String(String(format:"%f", personFilterIdNS!.doubleValue).prefix(7))
                
                    if(dynamicFilterArray[1].filterValues[0].group == 1){
                            params = params + "&detailList=" + personFilterId
                    }else if(dynamicFilterArray[1].filterValues[0].group == 2){
                            params = params + "&checkList=" + personFilterId
                    }else if(dynamicFilterArray[1].filterValues[0].group == 3){
                            params = params + "&priceList=" + personFilterId
                    }else{
                    }
            }
        }
    // Ürün grubu yada çeşidi..
        if(selectedIndex != -1){
            
            let productGroupNS = dynamicFilterArray[2].filterValues[selectedIndex].id
            let productGroupFilterId = String(String(format:"%f", productGroupNS!.doubleValue).prefix(7))
            if(dynamicFilterArray[2].filterValues[selectedIndex].group == 1){
                    params = params + "&detailList=" + productGroupFilterId
            }else if(dynamicFilterArray[2].filterValues[selectedIndex].group == 2){
                    params = params + "&checkList=" + productGroupFilterId
            }else if(dynamicFilterArray[2].filterValues[selectedIndex].group == 3){
                    params = params + "&priceList=" + productGroupFilterId
            }else{
            }
        }
// TO DO: Daha düzgün yapılabilir karıştı ve uzadı
        if(categoryButtonArray[2].isSelected == true && personButton.isSelected == true ){
                tableView.isHidden = false
                productGroupView.isHidden = false
        }else if((categoryButtonArray[0].isSelected == true || categoryButtonArray[1].isSelected == true) && personButton.isSelected == false){
            tableView.isHidden = false
            productGroupView.isHidden = false
        }else if(categoryButtonArray[2].isSelected == true && personButton.isSelected == false){
            tableView.isHidden = false
            productGroupView.isHidden = false
        }else if(personButton.isSelected == true){
            tableView.isHidden = false
            productGroupView.isHidden = false
        }else{
            tableView.isHidden = true
            productGroupView.isHidden = true
            }
        
    }
    
    
// MARK: Category button actions && personButton
    
    @IBAction func categoryButton1Pressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categoryButton2.isSelected = false
        categoryButton3.isSelected = false
        checkFilters()
        getFilterRequest()
    }
    
    @IBAction func categoryButton2Pressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categoryButton1.isSelected = false
        categoryButton3.isSelected = false
        checkFilters()
        getFilterRequest()
    }
    
    @IBAction func categoryButton3Pressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categoryButton1.isSelected = false
        categoryButton2.isSelected = false
        checkFilters()
        getFilterRequest()
    }
    
    @IBAction func personButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        checkFilters()
        getFilterRequest()
    }

// MARK: Filter request & parsing
    
    func getFilterRequest(){
        
        let reqUrl = requestUrl.productList.rawValue + "?" + params
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
        self.tableView.reloadData()
            if(dynamicFilterArray[0].name != nil){
                setupDynamicUI()
            }
       }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(dynamicFilterArray.count != 0){
            return self.dynamicFilterArray[2].filterValues.count
        }else{
            return 0
        }
       
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
//  TODO:  cell customization // dışarı alınmalı!!
        cell.textLabel?.text = self.dynamicFilterArray[2].filterValues[indexPath.row].name
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = #colorLiteral(red: 0.8980392157, green: 0.4745098039, blue: 0.8862745098, alpha: 1)
        cell.textLabel?.shadowColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        cell.textLabel?.shadowOffset = CGSize(width: -1.0, height: -1.0)
        cell.backgroundColor = #colorLiteral(red: 1, green: 0.9556375146, blue: 1, alpha: 0.8990151849)
        cell.layer.cornerRadius = 16.0
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.4745098039, blue: 0.8862745098, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        cell.textLabel?.highlightedTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.textLabel?.font = UIFont(name:"System", size: 15.0)
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
// TO DO: tablevie select deselect
    // select deselect yapısını kurmaya zamanım kalmadı :) table da cell seçili kalacak :(
/*        if(selectedIndex == -1){
            if(selectedIndex == indexPath.row){
                tableView.deselectRow(at: indexPath, animated: true)
                selectedIndex = -1
            }
        }
 */
        selectedIndex = indexPath.row
    }
}
