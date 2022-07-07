//
//  ViewController.swift
//  swiftdemo
//
//  Created by gzj on 2022/2/10.
//  Copyright © 2022 zengzuo. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var textField: PFTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
      
        textField.didBeginEditingHandler = { (textField) -> Void in
            
            print("1111111  didBeginEditingHandler")
        }
        
      
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
}




