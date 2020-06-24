//
//  VegViewController.swift
//  Inventory
//
//  Created by Ayman Zaher on 2019-03-31.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit
struct InventoryArray {
    var id: Int
    var name: String
    var quantity: Int
    var seconds: Int
}


class VegViewController: UIViewController {

    @IBOutlet weak var vegView: UITableView!
    @IBOutlet weak var vegSearch: UISearchBar!
    var vegArray : [InventoryArray] = []
    var filteredVeg: [InventoryArray] = []
    var filtering: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        vegView.delegate = self
        vegView.dataSource = self
        vegSearch.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        vegArray = []
        vegView.reloadData()
        downloadItems(urlPath: "http://159.89.119.141/service_veg.php")
    }
    
    func downloadItems(urlPath: String) {
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
            
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
            if let name = jsonElement["name"] as? String,
                let quantity = jsonElement["quantity"] as? String,
                let id = jsonElement["id"] as? String, let seconds = jsonElement["seconds"] as? String {
            print("\(id) - \(name) - \(quantity) - \(seconds)")
                let veg = InventoryArray(id: Int(id)!, name: name, quantity: Int(quantity)!,seconds: Int(seconds)!)
                vegArray.append(veg)
            }
            
        }
        DispatchQueue.main.async(execute: { () -> Void in
            if self.filtering == true {
            self.filteredVeg = self.vegArray.filter({ (text) -> Bool in
                return text.name.range(of: self.vegSearch.text!, options: .caseInsensitive) != nil
            })
                if self.vegSearch.text == "" {
                    self.filteredVeg = self.vegArray
                }
            } else {
                self.filteredVeg = self.vegArray
            }
            self.vegView.reloadData()
        })
    }
    @IBAction func reloadBttn(_ sender: Any) {
        vegArray = []
        vegView.reloadData()
        downloadItems(urlPath: "http://159.89.119.141/service_veg.php")
    }
    
}

extension VegViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVeg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = filteredVeg[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel!.text = "Quantity: \(String(item.quantity))"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateManger.shared.array = filteredVeg
        updateManger.shared.row = indexPath.row
    }
    
    
}

extension VegViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            filtering = true
            filteredVeg = vegArray.filter({ (text) -> Bool in
                return text.name.range(of: searchText, options: .caseInsensitive) != nil
            })
        } else {
            filteredVeg = vegArray
        }
        
        vegView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredVeg = vegArray
        filtering = false
        vegView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if vegSearch.text == "" {
            filtering = false
        }
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
