//
//  FilterViewController.swift
//  CicekSepeti
//
//  Created by RECEP CAN BABAOGLU on 18.07.2020.
//  Copyright © 2020 Can Babaoğlu. All rights reserved.
//

import UIKit

protocol sendFilterDelegateProtocol {
    func sendDataToFirstViewController(myData: String)
}

class FilterViewController: UIViewController {
    
    var delegate: sendFilterDelegateProtocol? = nil
    
    @IBOutlet var listButton: UIButton!
    @IBOutlet var filterView: UIView!
    
    var mainViewController:ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        listButton.layer.cornerRadius = 16
        filterView.layer.cornerRadius = 16
        listButton.layer.shadowColor = #colorLiteral(red: 0.7843137255, green: 0.5882352941, blue: 0.7843137255, alpha: 1)
        listButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        listButton.layer.shadowOpacity = 0.8
        listButton.layer.shadowRadius = 16
        listButton.layer.masksToBounds = false
    }
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        if self.delegate != nil {
            let dataToBeSent = "deneme"
            self.delegate?.sendDataToFirstViewController(myData: dataToBeSent)
            dismiss(animated: true, completion: nil)
        }
    }
    

}
