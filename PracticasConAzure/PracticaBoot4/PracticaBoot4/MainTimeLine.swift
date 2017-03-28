//
//  MainTimeLine.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit

class MainTimeLine: UITableViewController {

    var model: [Any] = []
    let cellIdentier = "POSTSCELL"
    let client = MSClient(applicationURLString: Constants.azureAppServiceEndpoint)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullModel()
    }
    
    func hadleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Se comprueba si model tiene información
        if model.isEmpty {
            return 0
        }
        
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)

        // Se obtiene el objeto del modelo en cuestión
        let item = model[indexPath.row] as! Dictionary<String, Any>
        
        cell.textLabel?.text = item["title"] as? String

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowRatingPost", sender: indexPath)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowRatingPost" {
//            let vc = segue.destination as! PostReview
            // aqui pasamos el item selecionado
        }
    }

    // MARK: - Functions
    // Función que sincroniza el modelo con lo recuperado
    func pullModel() {
        client.invokeAPI("GetAllPublishPosts",
                         body: nil,
                         httpMethod: "GET",
                         parameters: nil,
                         headers: nil) {
                            (result, response, error) in
                            if let _ = error {
                                print("\(error?.localizedDescription)")
                                return
                            }
                            print("\(result)")
                            self.model = result as! [Any]
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
        }
    }
}
