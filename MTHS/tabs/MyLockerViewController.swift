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
            let tempLockerLocationAsString = String(lockerInfoAsDictionary["location"]!)
            let tempLockerComboAsString = String(lockerInfoAsDictionary["combo"]!)
            
            lockerNumberLabel.text = "Your locker number is: \(tempLockerNumberAsString)"
            lockerLocationLabel.text = "It is near room: \(tempLockerLocationAsString)"
            if tempLockerComboAsString != "" {
                savedCombinationTextbox.text = tempLockerComboAsString
            }
            
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
        // save the locker combination
        
        let tempCombination = savedCombinationTextbox.text
        
        if tempCombination! != "" {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let userLockerInfo = defaults.objectForKey("studentLockerInfo") {
                var lockerInfoAsDictionary = userLockerInfo as! [String:String]
                
                // remove and replace the user default data
                defaults.removeObjectForKey("studentLockerInfo")
                lockerInfoAsDictionary["combo"] = tempCombination
                defaults.setObject(lockerInfoAsDictionary, forKey: "studentLockerInfo")
                
                // now update database
                let tempCombo = lockerInfoAsDictionary["combo"]!
                let tempLocker = lockerInfoAsDictionary["locker_number"]!
                
                let originalPostURL = "https://my.mths.ca/mths_ios/combination_upload.php?ln=" + tempLocker + "&combo=" + tempCombo
                // if they pace spaces in the combo, we need to replace them with "%20" in the URL
                let postURL :String = originalPostURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

                let request = NSMutableURLRequest(URL: NSURL(string: postURL)!)
                request.HTTPMethod = "POST"
                // does not seem to do anything, but you need it
                let postString = ""
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                    guard error == nil && data != nil else {
                        // check for fundamental networking error
                        print("error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                        // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response!)")
                    }
                    
                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("responseString = \(responseString!)")
                    
                }
                task.resume()
                
                // show alert, to let them know it happened
                let alertController = UIAlertController(title: "Data Updated", message: "You have saved your combination to the database.", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)

            }
        }
        

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
