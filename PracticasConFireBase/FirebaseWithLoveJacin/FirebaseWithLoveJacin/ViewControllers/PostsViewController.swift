//
//  PostsViewController.swift
//  FirebaseWithLoveJacin
//
//  Created by Jose Sanchez Rodriguez on 30/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class PostsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    // Se establece una referencia a la raiz de la Base de Datos y además, crea un hijo llamado LigaWin
    // Si se queda hasta FIRDatabase.database().reference() se obtiene una referencia a la raiz de la Base de Datos
    let postsRef = FIRDatabase.database().reference().child("Posts")
    
    var model: [MyPost] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Se levanta un observador sobre la Base de Datos que escuchará los eventos de la misma
        postsRef.observe(FIRDataEventType.childAdded, with: { (snap) in
            // Se muestra por pantalla el valor del dato obtenido
            for myPostFB in snap.children {
                let myPost = MyPost(snap: myPostFB as? FIRDataSnapshot)
                self.model.append(myPost)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions

    @IBAction func addInFB(_ sender: Any) {
        addRecordInPosts()
    }
    
    //MARK: - Functions
    // Función que da de alta un registro en Base de Datos
    func addRecordInPosts() {
        // Referencia a la entidad Artículos que además la clave se autogenera
        let key = postsRef.child("Articulos").childByAutoId().key
        
        // Se establece el diccionario con los datos que se van a dar de alta
        let posts = ["title" : "Soy leyenda", "desc": "Mis pensamientos de este maravilloso libro"]
        
        // Se instancia el registro a dar de alta en la Base de Datos
        let recordInFB = ["\(key)" : posts]
        
        // Se da de alta el registro en la entidad Artículos
        postsRef.child("Articulos").updateChildValues(recordInFB)
    }
    
    // Función que recupera datos de Base de Datos
    
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
