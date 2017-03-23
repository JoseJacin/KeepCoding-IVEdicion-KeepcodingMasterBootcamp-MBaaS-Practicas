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
        let credentials = AZSStorageCredentials(accountName: Constants.AccountName, accountKey: Constants.AccountKey)
        
        do {
            // Se instancia la cuenta
            account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            // Se instancia el blobClient. Cliente que gestiona todos los Containers
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
                                           // Con esto se indica que se retornen todos los elementos
                                           maxResults: -1,
                                           completionHandler: { (error, containersResults) in
                                            
                                            // Si algo sale mal
                                            if let _ = error {
                                                print("\(error?.localizedDescription)")
                                                return
                                            }
                                            
                                            // Se añade al modelo el elemento que se acaba de extraer
                                            // En este momento se está machacando el contenido de model con lo recuperado
                                            if let containersResults = containersResults {
                                                self.model = containersResults.results
                                            }
                                            
                                            // Se realiza la descarga en segundo plano
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Se comprueba el tipo de segue
        if segue.identifier == "VerContainer" {
            // Se instancia el ViewController
            let vc = segue.destination as! ContainerBrowser
            vc.blobClient = blobClient
            vc.nameCurrentContainer = (sender as! AZSCloudBlobContainer).name
        }
    }
    
    //MARK: - Actions
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
        }
        
        return model.count
    }
    
    // Función que indica la celda pulsada
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDA", for: indexPath)
        
        let item = model[indexPath.row] as! AZSCloudBlobContainer
        
        cell.textLabel?.text = item.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Se obtiene la referencia al Container a consultar
        let item = model[indexPath.row] as! AZSCloudBlobContainer
        
        // Se ejectua
        performSegue(withIdentifier: "VerContainer", sender: item)
    }
}







