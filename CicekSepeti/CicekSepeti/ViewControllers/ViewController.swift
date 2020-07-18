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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, sendFilterDelegateProtocol {
         
    @IBOutlet var tableView: UITableView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var cicekSepetiButton: UIButton!
    
    var productArray: [ProductObject] = []
    let cellReuseIdentifier = "cicekCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
        getProductRequest()
      //  getProductRequestwithParam("2007101")
        
    }    
    
// MARK: SetupUI
    func setupUI(){
        tableView.layer.cornerRadius = 16
                
        filterButton.layer.cornerRadius = 16
        filterButton.layer.shadowColor = #colorLiteral(red: 0.7843137255, green: 0.5882352941, blue: 0.7843137255, alpha: 1)
        filterButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        filterButton.layer.shadowOpacity = 0.8
        filterButton.layer.shadowRadius = 16
        filterButton.layer.masksToBounds = false
        
        cicekSepetiButton.layer.cornerRadius = 16
        cicekSepetiButton.layer.shadowColor = #colorLiteral(red: 0.7843137255, green: 0.5882352941, blue: 0.7843137255, alpha: 1)
        cicekSepetiButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cicekSepetiButton.layer.shadowOpacity = 0.8
        cicekSepetiButton.layer.shadowRadius = 16
        cicekSepetiButton.layer.masksToBounds = false
    }

// MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getFilterSegue" {
            let filterVC: FilterViewController = segue.destination as! FilterViewController
            filterVC.delegate = self
        }
    }
    
// MARK: protocol filter data
    func sendDataToFirstViewController(parameters: [String : String]) {
        print(parameters)
        getProductRequestwithParam(parameters)
    }
    
 // MARK: refresh Button
    @IBAction func CicekSepetiButtonPressed(_ sender: UIButton) {
        getProductRequest()
    }

// MARK: Requests & Parsing
    
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
    
    func getProductRequestwithParam(_ params: [String : String]){ // filtre tiplerine göre parametreler ekliyoruz.
        
        let reqUrl = requestUrl.productList.rawValue
        
       let dparameters = ["detailList":"2007217","checkList":"2007124"]
        
        Alamofire.request(reqUrl, method: .get, parameters: params ).responseJSON { response in
            
                if (response.result.isSuccess){
                    self.JSONParser(requestResponse: response.result.value as! NSDictionary)
               }else {
                    print("Error: \(String(describing: response.result.error))")
               }
            self.tableView.reloadData()
           }
       }
    
    func JSONParser(requestResponse: NSDictionary){
                       
        productArray.removeAll()
        let responseResult: NSDictionary = requestResponse.object(forKey: "result") as! NSDictionary
        let resultData: NSDictionary = responseResult.object(forKey: "data") as! NSDictionary
        let dataProducts: NSArray = resultData.object(forKey: "products") as! NSArray
        self.productArray.removeAll()
            for i in 0..<dataProducts.count{
                
                let tempProduct = ProductObject()
                tempProduct.Name = ((dataProducts[i] as AnyObject).object(forKey: "name") as! String)
                tempProduct.Image = ((dataProducts[i] as AnyObject).object(forKey: "image") as! String)
                let priceDictionary = ((dataProducts[i] as AnyObject).object(forKey: "price") as! NSDictionary)
                let desdes = (priceDictionary["current"]) as! NSNumber
                tempProduct.Price = String(format:"%f", desdes.doubleValue)
                
                self.productArray.append(tempProduct)
               }
        self.tableView.reloadData()
       }
    
// MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:CustomCicekCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CustomCicekCell

        cell.cicekView.loadImageUsingCache(withUrl: self.productArray[indexPath.row].Image!)
        cell.cicekCellPriceLabel.text = (self.productArray[indexPath.row].Price?.prefix(5))! + " TL" // ilk 5 hanesini almak için .prefix()
        cell.cicekCellLabel.text = self.productArray[indexPath.row].Name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
}

// MARK: ImageView extesion:
// StackOverFlow'da gördüm pod kurmak yerine denedim güzel çalıştı :)

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

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        let xPose = self.center.x - 20
        let yPose = self.center.x - 20
        activityIndicator.center = CGPoint(x: xPose, y: yPose)

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
