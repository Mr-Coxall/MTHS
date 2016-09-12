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
    @IBOutlet weak var year2017Label: UILabel!
    @IBOutlet weak var year2016Label: UILabel!
    @IBOutlet weak var studentCardBackground: UIImageView!
    @IBOutlet weak var iPhoneWarningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check size of the device
        let screenSize = UIScreen.mainScreen().nativeBounds
        print(screenSize)
        
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
            //print(studentPhoto)
            
            // so ... if it is an iPad Pro 12.9", then I need to move around the student card
            let iPadProLargeScreenSize = CGRect(x:0.0, y: 0.0, width: 2048.0, height: 2732.0)
            if iPadProLargeScreenSize == screenSize {
                // 12.9" iPadPro
                //print("Here")
                let rotate = CGAffineTransformMakeRotation(CGFloat(0.0))
                let translate = CGAffineTransformTranslate(CGAffineTransformIdentity, -145.0, -130.0)
                studentCardBackground.transform = CGAffineTransformConcat(rotate, translate)
            }
            
        } else {
            // if user is not logged in, then student info needs to not be accessable
            // tsest
            
        }
        
        // check if it is an iPad or iPhone, to rotate stuff
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            // It's an iPhone
            //print("iPhone")

            studentNameLabel.hidden = true
            studentNumberLabel.hidden = true
            studentBarCodeLabel.hidden = true
            studentPhotoImage.hidden = true
            year2017Label.hidden = true
            year2016Label.hidden = true
            studentCardBackground.hidden = true
            
        case .Pad:
            // It's an iPad
            //print("iPad")
            iPhoneWarningLabel.hidden = true
            
        default:
            // Uh, oh! What could it be?
            print("You are in trouble!")
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
