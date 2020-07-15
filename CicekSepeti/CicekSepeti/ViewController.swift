//
//  ViewController.swift
//  CicekSepeti
//
//  Created by Can Babaoğlu on 15.07.2020.
//  Copyright © 2020 Can Babaoğlu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    var ProductArray: [ProductObject] = []
    var tempProduct = ProductObject()

    override func viewDidLoad() {
        super.viewDidLoad()
        getRequestFromLibrary()
        
        
    }                               
    
    
    func getRequestFromLibrary(){ // alamofire request
                
        let reqUrl = "https://api.ciceksepeti.com/v1/product/ch/dynamicproductlist"
        
        Alamofire.request(reqUrl, method: .get).responseJSON { response in
            
            if (response.result.isSuccess){

                let requestResponse = response.result.value as! NSDictionary
                let responseResult: NSDictionary = requestResponse.object(forKey: "result") as! NSDictionary
                let resultData: NSDictionary = responseResult.object(forKey: "data") as! NSDictionary
                let dataProducts: NSArray = resultData.object(forKey: "products") as! NSArray
          //      let productsPrice: NSArray = dataProducts.object(at: ) as! NSArray

                for i in 0..<dataProducts.count{
                    self.tempProduct.Name = ((dataProducts[i] as AnyObject).object(forKey: "name") as! String)
                    self.tempProduct.Image = ((dataProducts[i] as AnyObject).object(forKey: "image") as! String)
                    let priceDictionary = ((dataProducts[i] as AnyObject).object(forKey: "price") as! NSDictionary)
            //        self.tempProduct.Price = (priceDictionary["current"] as! String)
                    
                    self.ProductArray.insert(self.tempProduct, at: i)
                }
                
            }else {
                print("Error: \(String(describing: response.result.error))")
            }
                 
        }
        
        
    }
    


}

