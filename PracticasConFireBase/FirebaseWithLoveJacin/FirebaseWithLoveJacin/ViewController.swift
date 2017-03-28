//
//  ViewController.swift
//  FirebaseWithLoveJacin
//
//  Created by Jose Sanchez Rodriguez on 28/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Se envía un evento de Pantalla a Goolge Analitics
        FIRAnalytics.setScreenName("MainViewController", screenClass: "Main")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Actions
    @IBAction func evento1Action(_ sender: Any) {
        // Se envía un evento de log a Goolge Analitics
        FIRAnalytics.logEvent(withName: "Action1",
                              parameters: ["producto" : "Manzanas" as NSObject,
                                           "cantidad": "20" as NSObject])

    }
    @IBAction func evento2Action(_ sender: Any) {
        // Se envía un evento de log a Goolge Analitics
        FIRAnalytics.logEvent(withName: "Action2",
                              parameters: ["Cesta" : 25 as NSObject])

    }
}

