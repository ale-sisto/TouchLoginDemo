//
//  LoginViewController.swift
//  TouchLoginDemo
//
//  Created by Ale on 10/12/14.
//  Copyright (c) 2014 Alessandro Sisto, Marco Donati. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let accounts = [("root","alpine") , ("admin", "password")] //hardcoded test accounts
    
    private let touchIDKey = "kTouchID"
    private let segueID = "loginSegue"
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var touchIDButton: UIButton!
    
    
    //MARK: Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.delegate = self
        passwordTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back",
            style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        touchIDButton.hidden = !(NSUserDefaults.standardUserDefaults().boolForKey(touchIDKey)
            && LAContext().canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil))
        userTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueID {
            let controller = segue.destinationViewController as OptionsViewController
            controller.username = self.userTextField.text
            controller.password = self.passwordTextField.text
        }
    }
    
    //MARK: Actions
    
    @IBAction func logIn() {
        if accounts.filter({ (u,p) in u == self.userTextField.text
            && self.passwordTextField.text == p }).count == 1 {
         performSegueWithIdentifier(segueID, sender: nil)
        } else {
            let vc = UIAlertController(title: "Error",
                message: "Wrong username or password", preferredStyle: .Alert)
            vc.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logInTouchID(sender: UIButton) {
        let context = LAContext()
        context.localizedFallbackTitle = "" // hides fallback button
        context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Touch to login", reply: { (success : Bool, err : NSError!) in
                //evaluate policy closure runs in a background thread!
                if success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let (user, pass) = KeychainManager().accountAndPassword() {
                            println("Keychain entry retrieved: \(user), \(pass))")
                            self.userTextField.text = user
                            self.passwordTextField.text = pass
                            self.logIn()
                        } else {
                            let vc = UIAlertController(title: "Error",
                                message: "Could not retrieve username or password", preferredStyle: .Alert)
                            vc.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                            self.presentViewController(vc, animated: true, completion: nil)
                        }
                    })
                }
            })
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == userTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            logIn()
        }
        return true
    }
    
    //MARK: utils
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
