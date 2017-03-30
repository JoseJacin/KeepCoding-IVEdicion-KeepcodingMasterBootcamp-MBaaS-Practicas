//
//  AppDelegate.swift
//  FirebaseWithLoveJacin
//
//  Created by Jose Sanchez Rodriguez on 28/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    //MARK: - Init
    override init() {
        FIRApp.configure()
    }
    
    //MARK: - Lyfecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Se levanta el Singleton de Firebase. Se levanta el cliente de Firebase
        //FIRApp.configure()
        
        // Se asocia el ID de cliente de Firebase al ID de Cliente de GoogleID
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        // Se establece como delegado de GoogleID el propio AppDelegate
        GIDSignIn.sharedInstance().delegate = self
        
        // Se levanta el Singleton de GoogleID
        
        
        return true
    }
    
    //MARK: - Functions
    // Función 
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Manejador de Login en GoogleID
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

//MARK: - Extensions
extension AppDelegate {
    // Método delegado de Login de GoogleID
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Se comprueba si ha ocurrido algún error
        if let _ = error {
            print("Error en Login en GoogleID")
            return
        }
        
        // Se comprueba si el usuario autenticado recibido en el método delegato es correcto
        guard let authForFirebase = user.authentication else {
            return
        }
        
        // Se genera un credencial válido por parte de Firebase a partir del token recibido de GoogleID
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: authForFirebase.idToken, accessToken: authForFirebase.accessToken)
        
        // Se reautentica el usuario con los credenciales de Firebase generados
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            // Se comprueba si ha ocurrido algún error
            if let _ = error {
                print("Error Login en Firebase con los credenciales de GoogleID")
                return
            }
            print(user?.displayName ?? "")
        })
        
    }
    
    // Método delegado de Logout de GoogleID
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(user.userID)
    }
}
