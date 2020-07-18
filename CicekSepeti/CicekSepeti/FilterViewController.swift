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
    
    var mainViewController:ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        listButton.layer.cornerRadius = 20
      //  listButton.layer.borderWidth = 0.5
      //  listButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        if self.delegate != nil {
            let dataToBeSent = "deneme"
            self.delegate?.sendDataToFirstViewController(myData: dataToBeSent)
            dismiss(animated: true, completion: nil)
        }
    }
    

}
