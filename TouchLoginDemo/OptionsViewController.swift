//
//  OptionsViewController.swift
//  TouchLoginDemo
//
//  Created by Ale on 10/12/14.
//  Copyright (c) 2014 Alessandro Sisto, Marco Donati. All rights reserved.
//

import UIKit


class OptionsViewController: UITableViewController {

    private let touchIDKey = "kTouchID"
    private let headerTitle = "Options"
    private let rowHeight : CGFloat = 64
    
    private var differentUser = false
    
    var username : String?
    var password : String?
    
    //MARK: Controller Lifecycle
    
    override func viewDidLoad() {
        if let savedUser = KeychainManager().account() {
            differentUser = username != savedUser
        }
        navigationItem.title = "Welcome \(username!.capitalizedString)"
    }
    
    //MARK: TableView Delegate & Datasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("optionCell") as OptionsCell
        c.title.text = "Touch ID"
        c.touchIDSwitch.setOn(true, animated: false)
        if c.touchIDSwitch.actionsForTarget(self, forControlEvent: .ValueChanged) == nil {
            c.touchIDSwitch.addTarget(self, action: "updateTouchId:", forControlEvents: .ValueChanged)
        }
        c.touchIDSwitch.on = !differentUser && NSUserDefaults.standardUserDefaults().boolForKey(touchIDKey)
        return c
    }
    
    //MARK: Actions
    
    func updateTouchId(sender: UISwitch) {
        if(differentUser && sender.on) {
            let vc = UIAlertController(title: "Warning",
                message: "Touch ID activated for a different user", preferredStyle: .Alert)
            vc.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                sender.on = false }))
            vc.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { action in
                if self.username != nil && self.password != nil {
                    let success = KeychainManager().update(self.username!, password: self.password!)
                    println("Keychain entry updated: \(success). (\(self.username!), \(self.password!))")
                    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: self.touchIDKey)
                    self.differentUser = false
                }
            }))
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: touchIDKey)
            if sender.on {
                if username != nil && password != nil {
                    let success = KeychainManager().add(self.username!, password: self.password!)
                    println("Keychain entry created: \(success). (\(self.username!), \(self.password!))")

                }
            } else {
                let success = KeychainManager().delete()
                println("Keychain entry deleted: \(success)")
            }
        }
    }
}
