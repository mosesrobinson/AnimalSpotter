//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    var apiController = APIController()
    
    //Table view data source
    var animalNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if apiController.bearer == nil {
            
            // perform if bearer/token is empty. 
            
            performSegue(withIdentifier: "LoginViewModalSegue", sender: nil)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)

        let animalnName = animalNames[indexPath.row]
        cell.textLabel?.text = animalnName

        return cell
    }

    // MARK: - Actions
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        // perform the network call to get the names
        // show them on the screen
        
        apiController.getAllAnimalNames { (result) in
            
            do {
                self.animalNames = try result.get()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                NSLog("Error getting all animals")
            }
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "LoginViewModalSegue" {
            if let destination = segue.destination as? LoginViewController {
                
                destination.apiController = apiController
            }
        }
    }
}
