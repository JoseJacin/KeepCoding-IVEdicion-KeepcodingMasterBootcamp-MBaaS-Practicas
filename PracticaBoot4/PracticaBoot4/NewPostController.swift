//
//  NewPostController.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit

class NewPostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Constants
    let tableNamePosts = "Posts"
    let azureAppServiceEndpoint = "https://webmobileboot4jjacin.azurewebsites.net"
    let AccountName = "josejboot4"
    let AccountKey = "zoEj+gvaq3XkXuljNE+sALVUfZpBT9YFubWaasy/HjrppJJzDSoioyiAG05HkzJR055xRZH9U/XQ8wyFa1qpEQ=="
    let containerPhotos = "fotos"
    
    //MARK: - Properties
    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextField!
    @IBOutlet weak var imagePost: UIImageView!
    
    var client: MSClient!
    var isReadyToPublish: Bool = false
    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAzureAppService()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    @IBAction func publishAction(_ sender: Any) {
        isReadyToPublish = (sender as! UISwitch).isOn
    }

    @IBAction func savePostInCloud(_ sender: Any) {
        // preparado para implementar codigo que persita en el cloud
        newPostInService(titlePostTxt.text!, textPostTxt.text!, isReadyToPublish, UIImageJPEGRepresentation(imagePost.image!, 0.5))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - funciones para la camara
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Selecciona la fuente de la imagen", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Ussar la libreria", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Usar la camara", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }

}

// MARK: - Delegado del imagepicker
extension NewPostController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
}

//MARK: - Extensions
// Métodos para AppService
extension NewPostController {
    // Método que genera la conexión
    func setupAzureAppService() {
        // Se instancia la conexión
        client = MSClient(applicationURLString: azureAppServiceEndpoint)
    }
    
    // Método que permite la subida del Post
    func newPostInService(_ title: String, _ description: String, _ status: Bool, _ imgData: Data! = nil) {
        // Se crea la referecia a la tabla destino
        let posts = client.table(withName: tableNamePosts)
        
        // Se realiza el insert en la tabla
        posts.insert(["title":title, "postDescription":description, "status":status]) { (result, error) in
            // Se comprueba si algo ha ido mal
            if let _ = error {
                print("\(error)")
                return
            }
            
            // Se comprueba si la imagen no es nulo
            if let _ = imgData {
                // Se sube la foto (blob)
                self.uploadDataPost(data: imgData, completionHandler: { (blobName) in
                    let item = ["id" : (result?["id"] as! String), "photo" : blobName]
                    posts.update(item, completion: { (result, error) in
                        // Se comprueba si algo ha ido mal
                        if let _ = error {
                            print("Error ---> \(error?.localizedDescription)")
                            return
                        }
                        print("\(result)")
                    })
                })
            }
        }
    }
    
    // Función que sube la foto del Post
    func uploadDataPost(data: Data, completionHandler: @escaping ((_: String?) -> Void)) {
        // Se instancian los credenciales
        let credentials = AZSStorageCredentials(accountName: AccountName, accountKey: AccountKey)
        
        do {
            // Se instancia la cuenta
            let account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            // Se instancia el blobClient. Cliente que gestiona todos los Containers
            let blobClient = account.getBlobClient()
            
            // Se crea la referencia al container
            let container = blobClient?.containerReference(fromName: containerPhotos)
            
            // Se instancia el blob
            let blobBlock = container?.blockBlobReference(fromName: String("\(UUID().uuidString).jpg"))
            
            // Se realiza la subida del blob
            blobBlock?.upload(from: data, completionHandler: { (error) in
                // Se comprueba si algo ha ido mal
                if error == nil {
                    // Si todo ha ido bien, se retorna el nombre del blob
                    completionHandler(blobBlock?.blobName)
                } else {
                    // Si algo ha ido mal no se hace nada
                    completionHandler(nil)
                }
            })
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}












