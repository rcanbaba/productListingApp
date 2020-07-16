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


enum requestUrl: String{
    case productList = "https://api.ciceksepeti.com/v1/product/ch/dynamicproductlist"
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]

    // These are the colors of the square views in our table view cells.
    // In a real project you might use UIImages.
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]

    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "cicekCell"

    @IBOutlet var tableView: UITableView!
    
    var productArray: [ProductObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getProductRequest()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:CustomCicekCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CustomCicekCell

        cell.cicekView.loadImageUsingCache(withUrl: self.productArray[indexPath.row].Image!)
        cell.cicekCellPriceLabel.text = (self.productArray[indexPath.row].Price?.prefix(5))! + " TL"
        cell.cicekCellLabel.text = self.productArray[indexPath.row].Name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
       
    func getProductRequest(){
        
        let reqUrl = requestUrl.productList.rawValue
        
        Alamofire.request(reqUrl, method: .get).responseJSON { response in
            
               if (response.result.isSuccess){
                   self.JSONParser(requestResponse: response.result.value as! NSDictionary)
                
               }else {
                   print("Error: \(String(describing: response.result.error))")
                  
               }
            
            self.tableView.reloadData()
            
           }
       }
       
    func JSONParser(requestResponse: NSDictionary){
                           
        let responseResult: NSDictionary = requestResponse.object(forKey: "result") as! NSDictionary
        let resultData: NSDictionary = responseResult.object(forKey: "data") as! NSDictionary
        let dataProducts: NSArray = resultData.object(forKey: "products") as! NSArray
    
            for i in 0..<dataProducts.count{
                
                let tempProduct = ProductObject()
                tempProduct.Name = ((dataProducts[i] as AnyObject).object(forKey: "name") as! String)
                tempProduct.Image = ((dataProducts[i] as AnyObject).object(forKey: "image") as! String)
                let priceDictionary = ((dataProducts[i] as AnyObject).object(forKey: "price") as! NSDictionary)
                let desdes = (priceDictionary["current"]) as! NSNumber
                tempProduct.Price = String(format:"%f", desdes.doubleValue)
                
                self.productArray.append(tempProduct)
               }
                     
       }
    
}

let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.center

        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                    activityIndicator.removeFromSuperview()
                }
            }

        }).resume()
    }
}
