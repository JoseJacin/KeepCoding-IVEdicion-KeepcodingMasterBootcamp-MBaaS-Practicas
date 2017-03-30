//
//  SecondViewController.swift
//  FirebaseWithLoveJacin
//
//  Created by Jose Sanchez Rodriguez on 28/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Se envía un evento de Pantalla a Goolge Analitics
        FIRAnalytics.setScreenName("SecondViewController", screenClass: "Second")
    }

    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Se envía un evento de log a Goolge Analitics
        FIRAnalytics.logEvent(withName: "Fin_SecondViewController", parameters: [kFIRParameterFlightNumber: "" as NSObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func evento3Action(_ sender: Any) {
        // Se envía un evento de log a Goolge Analitics
        FIRAnalytics.logEvent(withName: "Action3",
                              parameters: ["producto_description" : "Manzanas" as NSObject])
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
