//
//  MyLockerViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class MyLockerViewController: UIViewController {
    
    @IBOutlet weak var lockerInfoLabel: UILabel!
    @IBOutlet weak var lockerNumberLabel: UILabel!
    @IBOutlet weak var lockerLocationLabel: UILabel!
    @IBOutlet weak var savedCombinationLabel: UILabel!
    @IBOutlet weak var savedCombinationTextbox: UITextField!
    @IBOutlet weak var saveCombinationButton: UIButton!
    @IBOutlet weak var combinationReminder: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check if user is logged in
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userLockerInfo = defaults.objectForKey("studentLockerInfo") {
            //print(userLockerInfo)
            let lockerInfoAsDictionary = userLockerInfo as! [String:String]
            
            // there is locker info, so remove warning
            lockerInfoLabel.alpha = 0.0
            
            let tempLockerNumberAsString = String(lockerInfoAsDictionary["locker_number"]!)
            lockerNumberLabel.text = "Your locker number is: \(tempLockerNumberAsString)"
        } else {
            // if user is not logged in, then student info needs to not be accessable
            // tsest
            
            lockerNumberLabel.alpha = 0.0
            lockerLocationLabel.alpha = 0.0
            savedCombinationLabel.alpha = 0.0
            savedCombinationTextbox.alpha = 0.0
            saveCombinationButton.alpha = 0.0
            combinationReminder.alpha = 0.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveCombination(sender: AnyObject) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
