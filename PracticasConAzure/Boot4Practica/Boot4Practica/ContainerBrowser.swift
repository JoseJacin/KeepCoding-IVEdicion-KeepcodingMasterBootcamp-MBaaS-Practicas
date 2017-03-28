//
//  ContainerBrowser.swift
//  Boot4Practica
//
//  Created by Jose Sanchez Rodriguez on 22/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit

class ContainerBrowser: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Properties
    var blobClient: AZSCloudBlobClient!
    var nameCurrentContainer: String!
    var model: [AZSCloudBlockBlob]! = []
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Se establece el título del ViewController
        self.title = nameCurrentContainer
        
        // Se establece el DataSource y el Delegate
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        readAllBlobs(inContainer: nameCurrentContainer)
    }
    
    //MARK: - Actions
    @IBAction func uploadAction(_ sender: Any) {
        uploadLocalBlob()
    }
    
    //MARK: - Functions
    // Función que recupera todos los blob que tiene el container pasado por parámetro
    func readAllBlobs(inContainer current: String) {
        let container = blobClient.containerReference(fromName: current)
        
        container.listBlobsSegmented(with: nil,
                                     prefix: nil,
                                     useFlatBlobListing: true,
                                     blobListingDetails: AZSBlobListingDetails.all,
                                     maxResults: -1) { (error, results) in
                                        // Si algo sale mal
                                        if let _ = error {
                                            print("\(error?.localizedDescription)")
                                        }
                                        
                                        // Se recorren los elementos del results
                                        self.model = results?.blobs as! [AZSCloudBlockBlob]
                                        
                                        // Se realiza la descarga en segundo plano
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Función que realiza la descarga del blob
    fileprivate func downloadBlob(_ blob: AZSCloudBlockBlob) {
        // Se obtiene la referencia al Container
        let container = blobClient.containerReference(fromName: nameCurrentContainer)
        
        let blobLocal = container.blockBlobReference(fromName: blob.blobName)
        
        // Se crea una referencia a un blob
        blobLocal.downloadToData { (error, data) in
            if let _ = error {
                print("\(error?.localizedDescription)")
                return
            }
            
            if let _ = data {
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async {
                    // Se pasa la imagen al main thread
                    print("\(image.debugDescription)")
                }
            }
        }
    }
    
    // Función que sube un blob al container indicado
    func uploadLocalBlob() {
        let container = blobClient.containerReference(fromName: nameCurrentContainer)
        
        // Se crea una referencia al blob local
        let blobLocal = container.blockBlobReference(fromName: UUID().uuidString)
        
        // Se instancia la imgaen a subir
        let img = UIImageJPEGRepresentation(#imageLiteral(resourceName: "blobImg"), 0.5)!
        
        // Se sube el blob al container
        blobLocal.upload(from: img) { (error) in
            // Si hay error
            if error != nil {
                print("\(error.localizedDescription)")
                return
            }
            
            self.readAllBlobs(inContainer: self.nameCurrentContainer)
        }
    }
    
    // Función que elimina un blob del container indicado
    func deleteBlob(blobLocal: AZSCloudBlockBlob) {
        blobLocal.delete { (error) in
            if let _ = error {
                print("\(error?.localizedDescription)")
                return
            }
        }
    }
}

extension ContainerBrowser {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model[indexPath.row] as AZSCloudBlockBlob
        downloadBlob(item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDACONTAINER", for: indexPath)
        
        let item = model[indexPath.row] as AZSCloudBlockBlob
        
        cell.textLabel?.text = item.blobName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty {
            return 0
        }
        
        return model.count
    }
    
    // Función que activa el poder editar elementos de un tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Se consulta la acción ejecutada sobre la celda de la tabla
        if editingStyle == .delete {
            // Se indica que se activan las modificaciones
            tableView.beginUpdates()
            // Se elimina la celda de la tableView
            tableView.deleteRows(at: [indexPath], with: .fade)
            // Se elimina el elemento del modelo
            let item = model[indexPath.row] as AZSCloudBlockBlob
            model.remove(at: indexPath.row)
            // Se elimina del container
            deleteBlob(blobLocal: item)
            // Se indica que se desactiva la edición en la tableView
            tableView.endUpdates()
        }
    }
}
