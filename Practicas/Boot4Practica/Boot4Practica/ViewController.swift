//
//  ViewController.swift
//  Boot4Practica
//
//  Created by Jose Sanchez Rodriguez on 21/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Properties
    var account: AZSCloudStorageAccount!
    var blobClient: AZSCloudBlobClient!
    var model: [Any] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addNewContainer(_ sender: Any) {
        let containerRef = blobClient.containerReference(fromName: "ejemplo2")
        containerRef.createContainerIfNotExists(with: .container, requestOptions: nil, operationContext: nil) { (error, noExists) in
            // Si algo va mal
            if let _ = error {
                print("\(error?.localizedDescription)")
                return
            }
            
            // Si todo va bien
            if noExists {
                // Se refresca la información
                self.readAllContainers()
            }
        }
    }
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupAzureStorageConnect()
        
        // Se establece el DataSource y el Delegate
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Función que configura la conexión con Azure
    func setupAzureStorageConnect() {
        let credentials = AZSStorageCredentials(accountName: "josejboot4", accountKey: "zoEj+gvaq3XkXuljNE+sALVUfZpBT9YFubWaasy/HjrppJJzDSoioyiAG05HkzJR055xRZH9U/XQ8wyFa1qpEQ==")
        
        do {
            // Se instancia la cuenta
            account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            // Se instancia el blobClient
            blobClient = account.getBlobClient()
            
            // Se leen todos los Containers
            readAllContainers()
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    // Función que recupera los contenedores que tiene la cuenta de Azure
    fileprivate func readAllContainers() {
        blobClient.listContainersSegmented(with: nil,
                                           prefix: nil,
                                           containerListingDetails: AZSContainerListingDetails.all,
                                           maxResults: -1,
                                           completionHandler: { (error, containersResults) in
                                            
                                            // Si algo sale mal
                                            if let _ = error {
                                                print("\(error?.localizedDescription)")
                                                return
                                            }
                                            
                                            // Se añade al modelo el elemento que se acaba de extraer
                                            self.model = (containersResults?.results)!
                                            
                                            // Se realiza la descarga en segundo plano
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
        })
    }
}

extension ViewController {
    // Función que establece el número de secciones
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Función que establece el número de filas de cada sección
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty {
            return 0
        } else {
            return model.count
        }
    }
    
    // Función que indica la celda pulsada
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDA", for: indexPath)
        
        let item = model[indexPath.row] as! AZSCloudBlobContainer
        
        cell.textLabel?.text = item.name
        
        return cell
    }
}

