//
//  MyPost.swift
//  FirebaseWithLoveJacin
//
//  Created by Jose Sanchez Rodriguez on 31/3/17.
//  Copyright © 2017 Jose Sanchez Rodriguez. All rights reserved.
//

import Foundation
import Firebase

class MyPost: NSObject {
    
    //MARK: - Properties
    var title: String = ""
    var desc: String = ""
    var refInCloud: FIRDatabaseReference?
    
    //MARK: - Init
    init(title: String, desc: String) {
        self.title = title
        self.desc = desc
        self.refInCloud = nil
    }
    
    init(snap: FIRDataSnapshot?) {
        refInCloud = snap?.ref
        
        desc = (snap?.value as? [String: Any])?["desc"] as! String
        desc = (snap?.value as? [String: Any])?["title"] as! String

    }
    
    //Inicializador de conveniencia
    convenience override init() {
        self.init(title: "", desc: "")
    }
}
