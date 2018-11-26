//
//  ViewController+keyboard.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/11/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

extension UIViewController: UITextFieldDelegate{
    // Resigns keyboard if outside of an editable object is tapped
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

/* FIXME: does not work
extension UITableViewController{
    // Resigns keyboard if outside of an editable object is tapped
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
*/
