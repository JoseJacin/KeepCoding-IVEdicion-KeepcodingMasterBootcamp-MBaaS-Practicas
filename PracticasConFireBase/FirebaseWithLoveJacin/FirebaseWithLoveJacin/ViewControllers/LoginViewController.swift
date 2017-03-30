//
//  LoginViewController.swift
//  FirebaseWithLoveJacin
//
//  Created by Jose Sanchez Rodriguez on 29/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    //MARK: - Properties
    var handle: FIRAuthStateDidChangeListenerHandle!
    
    //MARK: - Typealias
    typealias actionUserCmd = (_ : String, _ : String) -> Void
    
    //MARK: - Enums
    enum ActionUser: String {
        case toLogin = "Login"
        case toSignIn = "Registrar nuevo usuario"
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        // Se añade un listener de autenticación para hacer Login
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            print("El mail del usuario logado \(user?.email ?? "")")
        })
    }
    
    //MARK: - Actions
    // Acción que se ejecuta cuando se pulsa el botón Login
    @IBAction func doLogin(_ sender: Any) {
        // Se muestra el Dialog de Login
        showUserLoginDialog(withCommand: login, userAction: .toLogin)
    }

    // Acción que se ejecuta cuando se pulsa el botón Login
    @IBAction func doLogout(_ sender: Any) {
        // Se comprueba si hay un usuario logado y si lo hay, se desloguea
        makeLogout()
    }
    
    // Acción que se ejecuta cuando se pulsa el botón Anómino
    @IBAction func doAnonimo(_ sender: Any) {
        // Se comprueba si hay un usuario logado y si lo hay, se desloguea
        makeLogout()
        
        // Se loguea con un usuario Anónimo
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let _ = error {
                print("Ha ocurrido un error al loguearse con un usuario Anónimo")
                return
            }
            print(user?.uid ?? "")
        })
    }
    
    //MARK: - Functions
    // Función que realiza el Login del usuario. Si este no existe, lo crea
    fileprivate func login(_ name: String, andPass pass: String) {
        FIRAuth.auth()?.signIn(withEmail: name, password: pass, completion: { (user, error) in
            
            // Se comprueba si algo ha salido mal
            if let _ = error {
                // Ha ocurrido un error
                print("Tenemos un error -> \(error?.localizedDescription ?? ""))")
                // Se crea el usuario
                FIRAuth.auth()?.createUser(withEmail: name, password: pass, completion: { (user, error) in
                    
                    // Se comprueba si algo ha salido mal
                    if let _ = error {
                        print("Tenemos un error -> \(error?.localizedDescription ?? ""))")
                        return
                    }
                })
                self.performSegue(withIdentifier: "launchWithLogged", sender: nil)
                return
            }
            print("user: \(user?.email! ?? "")")
        })
    }
    
    fileprivate func makeLogout() {
        // Se valida si hay un usuario logado
        if let _ = FIRAuth.auth()?.currentUser {
            // Hay un usuario logado, por lo que se procede a hacer el Logout
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                // Algo ha ido mal
                print(error)
            }
        }
    }
    
    // Método que captura las credenciales del usuario
    func showUserLoginDialog(withCommand actionCmd: @escaping actionUserCmd, userAction: ActionUser) {
        // Se instancia el controlador de alertas
        let alertController = UIAlertController(title: "FirebaseWithLove", message: userAction.rawValue, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: userAction.rawValue, style: .default, handler: { (action) in
            let eMailTxt = (alertController.textFields?[0])! as UITextField
            let passTxt = (alertController.textFields?[1])! as UITextField
            
            // Se comprueba si algo ha salido mal
            if (eMailTxt.text?.isEmpty)!, (passTxt.text?.isEmpty)! {
                // No continuar y lanzar error
            } else {
                actionCmd(eMailTxt.text!, passTxt.text!)
            }
        }))
        
        // Se agrega un botón para el Cancel
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
        }))
        
        // Se agregan los TextField al alert añadiendolos con Placeholder por defecto
        // TextField de cuenta de usuario
        alertController.addTextField { (txtField) in
            txtField.placeholder = "Por favor, escriba su mail"
            txtField.textAlignment = .natural
        }
        
        //TextField de pass de usuario
        alertController.addTextField { (txtField) in
            txtField.placeholder = "Por favor, escriba su password"
            txtField.textAlignment = .natural
            txtField.isSecureTextEntry = true
        }
        
        // Se muestra la alerta
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "launchWithLogged" {
            let controller = (segue.destination as! UINavigationController).topViewController as! ViewController
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}
