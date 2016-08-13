//
//  TechHelpViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit
import MessageUI

class TechHelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    

    @IBOutlet weak var techHelpLabel: UILabel!
    @IBOutlet weak var techHelpButton: UIButton!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check if you are currently logged in and have data stored locally
        if let studentName = defaults.stringForKey("studentName") {
            // logged in
            print("Loged in as:" + studentName)
            techHelpLabel.hidden = true
            techHelpButton.hidden = false

        } else {
            // NOT logged in !!
            techHelpLabel.hidden = false
            techHelpButton.hidden = true
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func techHelpButton(sender: AnyObject) {
        // send tech help email
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["help@mths.ca"])
            mail.setSubject("Tech Help Request")
            mail.setMessageBody("<b>I need help with ...</b>", isHTML: true)
            presentViewController(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            // give feedback to the user
        }

    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Saved")
        case MFMailComposeResultSent.rawValue:
            print("Sent")
        case MFMailComposeResultFailed.rawValue:
            print("Error: \(error?.localizedDescription)")
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
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
