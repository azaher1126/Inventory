//
//  VegUpdateViewController.swift
//  Inventory
//
//  Created by Ayman Zaher on 2019-03-31.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit

class VegUpdateViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var seconds: UILabel!
    
    @IBOutlet weak var updateSelector: UISegmentedControl!
    @IBOutlet weak var qualitySelector: UISegmentedControl!
    @IBOutlet weak var updateValue: UITextField!
    
    var ins: Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var array = updateManger.shared.array
        var row = updateManger.shared.row
        name.text = "Vegetable: \(array[row!].name)"
        quantity.text = "No. 1 Quantity: \(array[row!].quantity)"
        seconds.text = "No. 2 Quantity: \(array[row!].seconds)"
        if updateManger.shared.no == 2 {
            qualitySelector.selectedSegmentIndex = 1
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dates = formatter.string(from: date)
        print(dates)
        let url = URL(string: "http://159.89.119.141/get_veg.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = ("id=\(array[row!].id)&dates=\(dates)")
        print(postString)
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
            self.parseJSON(data)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        
        for i in 0 ..< jsonResult.count {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let ins = jsonElement["ins"] as? String {
            print("\(ins)")
                self.ins = Int(ins)
                print(self.ins)
            }
            
        }
        
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
    
    
    @IBAction func updateQuantity(_ sender: Any) {
        var array = updateManger.shared.array
        var row = updateManger.shared.row
        var newQuantity: Int = 0
        var quality = ""
        if qualitySelector.selectedSegmentIndex == 0 {
            quality = "quantity"
            if updateSelector.selectedSegmentIndex == 0 {
                print(array[row!].quantity + Int(updateValue.text!)!)
                newQuantity = array[row!].quantity + Int(updateValue.text!)!
            } else if updateSelector.selectedSegmentIndex == 1 {
                print(array[row!].quantity - Int(updateValue.text!)!)
                newQuantity = array[row!].quantity - Int(updateValue.text!)!
            }
        } else if qualitySelector.selectedSegmentIndex == 1 {
            quality = "seconds"
            if updateSelector.selectedSegmentIndex == 0 {
                print(array[row!].seconds + Int(updateValue.text!)!)
                newQuantity = array[row!].seconds + Int(updateValue.text!)!
            } else if updateSelector.selectedSegmentIndex == 1 {
                print(array[row!].seconds - Int(updateValue.text!)!)
                newQuantity = array[row!].seconds - Int(updateValue.text!)!
            }
        }
        func updateSummary () {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            let dates = formatter.string(from: date)
            let url = URL(string: "http://159.89.119.141/summary_veg.php")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = ("id=\(array[row!].id)&in=\(ins + Int(updateValue.text!)!)&dates=\(dates)")
            print(postString)
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
        }
        if checkaConnection() == true {
            let url = URL(string: "http://159.89.119.141/update_veg.php")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = ("id=\(array[row!].id)&quantity=\(newQuantity)&quality=\(quality)")
            print(postString)
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
            updateSummary()
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
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
