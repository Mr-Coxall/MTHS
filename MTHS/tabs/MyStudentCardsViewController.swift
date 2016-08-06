//
//  MyStudentCardsViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class MyStudentCardsViewController: UIViewController {

    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentNumberLabel: UILabel!
    @IBOutlet weak var studentBarCodeLabel: UILabel!
    @IBOutlet weak var studentPhotoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check if user is logged in
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userEmailAddress = defaults.stringForKey("userEmailAddress") {
            print(userEmailAddress)
            
            let studentName = defaults.stringForKey("studentName")
            studentNameLabel.text = studentName
            
            let studentNumber = defaults.stringForKey("studentNumber")
            studentNumberLabel.text = studentNumber
            
            let studentBarCode = "*" + studentNumber! + "*"
            studentBarCodeLabel.text = studentBarCode
            
            let studentPhoto = defaults.dataForKey("studentPhoto")
            studentPhotoImage.image = UIImage(data: studentPhoto!)
            print(studentPhoto)
        } else {
            // if user is not logged in, then student info needs to not be accessable
            // tsest
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
