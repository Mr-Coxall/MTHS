//
//  MyStudentCardsViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

// got this from: http://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift
extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

class MyStudentCardsViewController: UIViewController {

    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentNumberLabel: UILabel!
    @IBOutlet weak var studentBarCodeLabel: UILabel!
    @IBOutlet weak var studentPhotoImage: UIImageView!
    @IBOutlet weak var studentCardBackground: UIImageView!
    
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
            
            
            // check if it is an iPad or iPhone, to rotate stuff
            switch UIDevice.currentDevice().userInterfaceIdiom {
            case .Phone:
            // It's an iPhone
                //print("iPhone")
                
                // rotate labels
                let rotate = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                let translate = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, 0.0)
                
                studentNameLabel.transform = CGAffineTransformConcat(rotate, translate)
                studentNumberLabel.transform = CGAffineTransformConcat(rotate, translate)
                studentBarCodeLabel.transform = CGAffineTransformConcat(rotate, translate)
                studentPhotoImage.transform = CGAffineTransformConcat(rotate, translate)
                studentCardBackground.transform = CGAffineTransformConcat(rotate, translate)
                
                //let translate = CGAffineTransformMakeTranslation((studentNameLabel.bounds.height / 2)-(studentNameLabel.bounds.width / 2), (studentNameLabel.bounds.width / 2)-(studentNameLabel.bounds.height / 2))
                
                
                //let rotatedStudentPhoto = UIImage(data: studentPhoto!)!.imageRotatedByDegrees(-90, flip: false)
                //studentPhotoImage.image = UIImage(data: studentPhoto!)
                //studentPhotoImage.image = rotatedStudentPhoto
                
                //rotate the student card
                //let rotatedStudentCardBackground = studentCardBackground.image?.imageRotatedByDegrees(-90, flip: false)
                //studentCardBackground.image = rotatedStudentCardBackground
                
                // now move things around, depending on the screen size of the iPhone
                
                
            case .Pad:
            // It's an iPad
                //print("iPad")
                
                // so ... if it is an iPad Pro 12.9", then I need to move around the student card
                let iPadProLargeScreenSize = CGRect(x:0.0, y: 0.0, width: 2048.0, height: 2732.0)
                if iPadProLargeScreenSize == screenSize {
                    // 12.9" iPadPro
                    //print("Here")
                    let rotate = CGAffineTransformMakeRotation(CGFloat(0.0))
                    let translate = CGAffineTransformTranslate(CGAffineTransformIdentity, -145.0, -130.0)
                    studentCardBackground.transform = CGAffineTransformConcat(rotate, translate)
                }
                
            default:
                // Uh, oh! What could it be?
                print("You are in trouble!")
            }
            
            //print(studentPhoto)
        } else {
            // if user is not logged in, then student info needs to not be accessable
            // tsest
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        // happens just before view did load
        
        //self.exampleView.translatesAutoresizingMaskIntoConstraints = YES;
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
