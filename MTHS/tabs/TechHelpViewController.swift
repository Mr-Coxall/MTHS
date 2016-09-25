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
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check if you are currently logged in and have data stored locally
        if let studentName = defaults.string(forKey: "studentName") {
            // logged in
            print("Loged in as:" + studentName)
            techHelpLabel.isHidden = true
            techHelpButton.isHidden = false

        } else {
            // NOT logged in !!
            techHelpLabel.isHidden = false
            techHelpButton.isHidden = true
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func techHelpButton(_ sender: AnyObject) {
        // send tech help email
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["help@mths.ca"])
            mail.setSubject("Tech Help Request")
            mail.setMessageBody("<b>I need help with ...</b>", isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            // give feedback to the user
        }

    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(error?.localizedDescription)")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
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
