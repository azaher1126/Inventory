//
//  BoxesUpdateViewController.swift
//  Inventory
//
//  Created by Ayman Zaher on 2019-03-31.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit

class BoxesUpdateViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var updateSelector: UISegmentedControl!
    @IBOutlet weak var updateValue: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        var array = updateManger.shared.array
        var row = updateManger.shared.row
        name.text = "Box: \(array[row!].name)"
        quantity.text = "Quantity: \(array[row!].quantity)"
    }
    func checkaConnection() -> Bool {
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
        switch Network.reachability.status {
        case .unreachable:
            return false
        case .wwan:
            return true
        case .wifi:
            return true
        }
        
    }
    @IBAction func updateBttn(_ sender: Any) {
        var array = updateManger.shared.array
        var row = updateManger.shared.row
        var newQuantity: Int = 0
        if updateSelector.selectedSegmentIndex == 0 {
            print(array[row!].quantity + Int(updateValue.text!)!)
            newQuantity = array[row!].quantity + Int(updateValue.text!)!
        } else if updateSelector.selectedSegmentIndex == 1 {
            print(array[row!].quantity - Int(updateValue.text!)!)
            newQuantity = array[row!].quantity - Int(updateValue.text!)!
        }
        if checkaConnection() == true {
            let url = URL(string: "http://159.89.119.141/update_boxes.php")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = ("id=\(array[row!].id)&quantity=\(newQuantity)")
            request.httpBody = "\(postString)".data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
            }
            task.resume()
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "No Connection", message: "Could not update the quantity of \(array[row!].name) please check your internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

