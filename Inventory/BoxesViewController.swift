//
//  BoxesViewController.swift
//  Inventory
//
//  Created by Ayman Zaher on 2019-03-31.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import UIKit

class BoxesViewController: UIViewController {

    @IBOutlet weak var boxSearch: UISearchBar!
    @IBOutlet weak var boxView: UITableView!
    var boxArray: [InventoryArray] = []
    var filteredbox: [InventoryArray] = []
    var filtering: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        boxView.delegate = self
        boxView.dataSource = self
        boxSearch.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        boxArray = []
        boxView.reloadData()
        downloadItems(urlPath: "http://159.89.119.141/service_boxes.php")
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
                let id = jsonElement["id"] as? String {
                print("\(id) - \(name) - \(quantity)")
                let box = InventoryArray(id: Int(id)!, name: name, quantity: Int(quantity)!, seconds: 0)
                boxArray.append(box)
                
            }
            
        }
        DispatchQueue.main.async(execute: { () -> Void in
            if self.filtering == true {
                self.filteredbox = self.boxArray.filter({ (text) -> Bool in
                    return text.name.range(of: self.boxSearch.text!, options: .caseInsensitive) != nil
                })
                if self.boxSearch.text == "" {
                    self.filteredbox = self.boxArray
                }
            } else {
                self.filteredbox = self.boxArray
            }
            self.boxView.reloadData()
        })
    }
    @IBAction func reloadBttn(_ sender: Any) {
        boxArray = []
        boxView.reloadData()
        downloadItems(urlPath: "http://159.89.119.141/service_boxes.php")
    }
}

extension BoxesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredbox.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = filteredbox[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel!.text = "Quantity: \(String(item.quantity))"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateManger.shared.array = filteredbox
        updateManger.shared.row = indexPath.row
    }
    
}

extension BoxesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            filtering = true
            filteredbox = boxArray.filter({ (text) -> Bool in
                return text.name.range(of: searchText, options: .caseInsensitive) != nil
            })
        } else {
            filteredbox = boxArray
        }
        
        boxView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredbox = boxArray
        filtering = false
        boxView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if boxSearch.text == "" {
            filtering = false
        }
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
