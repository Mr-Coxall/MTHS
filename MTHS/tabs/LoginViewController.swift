//
//  LoginViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-09.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

// Google
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var loginButton: GIDSignInButton!
    @IBOutlet weak var logoutButton: GIDSignInButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var gettingDataActivityIndicator: UIActivityIndicatorView!
    
    // variables
    //var credential : FIRAuthCredential

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if you are currently logged in and have data stored locally
        let defaults = NSUserDefaults.standardUserDefaults()
        if let studentName = defaults.stringForKey("studentName") {
            print("User logger in:")
            print(studentName)
            loginButton.enabled = false
            logoutButton.enabled = true
            loginStatusLabel.alpha = 1.0
            self.loginStatusLabel.text = "Logged in as \(studentName)"
        } else {
            loginButton.enabled = true
            logoutButton.enabled = false
            loginStatusLabel.alpha = 0.0
        }
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Do any additional setup after loading the view.
        //let button = GIDSignInButton(frame: CGRectMake(0, 0, 100, 100))
        //button.center = view.center
        //view.addSubview(button)
        
        // Google Signin
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
 
        // make the Login Status label invisible
        gettingDataActivityIndicator.hidesWhenStopped = true
        gettingDataActivityIndicator.stopAnimating()

    }
    
    // Error during signing
    func errorDuringSigningProcess(errorThatOccured: String) {
        // something has gone wrong during signing,
        // so set everything back as if you are not signined in
        
        print(errorThatOccured)
        self.loginButton.enabled = false
        self.logoutButton.enabled = true
        self.gettingDataActivityIndicator.stopAnimating()
        self.loginStatusLabel.text = "Error occured while getting your student data, please contact the librarian."
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userEmailAddress")
        defaults.removeObjectForKey("studentName")
        defaults.removeObjectForKey("studentHomeroom")
        defaults.removeObjectForKey("studentNumber")
        defaults.removeObjectForKey("studentPhoto")
        defaults.removeObjectForKey("studentSchedule")
        
        let alert = UIAlertController(title: "Alert", message: "Unable to get your student data, please contact the librarian.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        let user = FIRAuth.auth()?.currentUser
        
        user?.deleteWithCompletion { error in
            if let error = error {
                // An error happened.
                print(error)
            } else {
                // Account deleted.
                print("Account deleted")
            }
        }
    }
    
    // Google Signin

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
        // start the signing process
        
        self.gettingDataActivityIndicator.startAnimating()
        self.loginStatusLabel.alpha = 1.0
        self.loginButton.enabled = false
        self.loginStatusLabel.text = "Signing process started."
        
        //print ("In view Controller")
        if let error = error {
            //self.showMessagePrompt(error.localizedDescription)
            print(error.localizedDescription)
            
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        // ...
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
            print(user?.email)
            
            // before authenticating, check to see it is a @ocsbstudent.ca Domain
            let fullEmail = user?.email
            let fullEmailArr = fullEmail!.characters.split{$0 == "@"}.map(String.init)
            if fullEmailArr[1] == "ocsbstudent.ca" {
                self.loginStatusLabel.text = "You have logged in as \(fullEmail)"
                if let user = FIRAuth.auth()?.currentUser {
                    for profile in user.providerData {
                        //let providerID = profile.providerID
                        //let uid = profile.uid;  // Provider-specific UID
                        //let name = profile.displayName
                        let email = profile.email
                        print(email!)
                        //let photoURL = profile.photoURL
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(email!, forKey: "userEmailAddress")
                    }
                } else {
                    // No user is signed in.
                    self.errorDuringSigningProcess("No user is signed in.")
                }
                
                print("Logged in started")
                
                // now need to get the user info from Chris's database
                self.loginStatusLabel.text = "Getting your student information " + "\r\n" + "from database." + "\r\n" + "This will take some time." + "\r\n" + "Please wait."
                
                let studentInfoRequestURL = NSURL (string: "https://my.mths.ca/patrick/mths_ios/student_json.php?email="+fullEmail!)
                let studentInfoURLRequest = NSURLRequest(URL: studentInfoRequestURL!)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(studentInfoURLRequest, completionHandler: { (data, response, error) in
                    guard let responseData = data else {
                        //print("Error: did not receive data")
                        self.errorDuringSigningProcess("Error: did not receive data")
                        
                        return
                    }
                    guard error == nil else {
                        //print("error calling GET on /posts/1")
                        self.errorDuringSigningProcess("error calling GET on /posts/1")
                        
                        return
                    }
                    
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(responseData, options: .MutableContainers) as! NSArray
                        // Do Stuff
                        print("Data retrieved from database")
                        
                        if jsonData.count==1 {
                            // if there is a single record
                            if let item = jsonData[0] as? [String: AnyObject] {
                                let studentReversedName = item["name"] as? String
                                let studentHomeroom = item["homeroom"] as? String
                                let studentNumberAsString = item["student_number"] as? String
                                
                                guard let studentNumber:Int = Int(studentNumberAsString!)! else {
                                    //print("Cannot convert student number to int")
                                    self.errorDuringSigningProcess("Cannot convert student number to int")
                                    
                                    return
                                }
                                
                                // get the order of student name correct
                                let studentNameArr = studentReversedName!.characters.split{$0 == ","}.map(String.init)
                                let studentName = studentNameArr[1] + " " + studentNameArr[0]

                                // add info to user defaults
                                print("Saving to user defaults")
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setObject(studentName, forKey: "studentName")
                                defaults.setObject(studentHomeroom!, forKey: "studentHomeroom")
                                defaults.setObject(studentNumber, forKey: "studentNumber")
                                
                                // now get the student photo
                                self.getStudentPhotoFromDatabase(studentNumber){ (responseStudentPhoto:UIImage?) in
                                    
                                    //print(responseStudentPhoto)
                                    let bgImage = UIImageView(image: responseStudentPhoto)
                                    bgImage.frame = CGRectMake(0,0,200,300)
                                    self.view.addSubview(bgImage)
                                    
                                    defaults.setObject(UIImagePNGRepresentation(responseStudentPhoto!), forKey: "studentPhoto")
                                }
                                
                                // now get student schedule
                                self.getStudentScheduleFromDatabase(studentNumber){ (responseStudentSchedule:[SchoolClass]?) in
                                    
                                    print(responseStudentSchedule)
                                    
                                    // an array of dictionaries
                                    var tempArrayOfClasses = [[String: String]()]
                             
                                    for tempClass in responseStudentSchedule! {
                                        var tempClassDictonary: [String:String] = [:]
                                        tempClassDictonary.updateValue(tempClass.course, forKey: "course")
                                        tempClassDictonary.updateValue(tempClass.period, forKey: "period")
                                        tempClassDictonary.updateValue(tempClass.room, forKey: "room")
                                        tempClassDictonary.updateValue(tempClass.semester, forKey: "semester")
                                        tempClassDictonary.updateValue(tempClass.teacher, forKey: "teacher")
                                        tempArrayOfClasses.append(tempClassDictonary)
                                    }

                                    // remove the first element, since it is empty
                                    tempArrayOfClasses.removeAtIndex(0)
                                    defaults.setObject(tempArrayOfClasses, forKey: "studentSchedule")
                                    print(tempArrayOfClasses)
  
                                }
                                
                                // finally done, you have good basic student info
                                //change over the login buttons
                                self.loginStatusLabel.text = "Logged in as \(studentName)"
                                self.loginButton.enabled = false
                                self.logoutButton.enabled = true
                                
                                // all done
                                self.gettingDataActivityIndicator.stopAnimating()
                                print("All done getting student data.")
                            } else {
                                print("error getting student data")
                                self.errorDuringSigningProcess("error getting student data")
                            }
                            
                        } else {
                            // no data for that student returned
                            print("No student data")
                            self.errorDuringSigningProcess("No student data")
                        }
                        
                    } catch {
                        // handle error
                    }

                })
                
                task.resume()
                
            } else {
                // not the correct domain
                print("You are not using the correct email address")
                self.loginButton.enabled = false
                self.logoutButton.enabled = true
                self.gettingDataActivityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Alert", message: "You are not using the correct email address. You must login using an @ocsbstudent.ca domain.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                let user = FIRAuth.auth()?.currentUser
                
                user?.deleteWithCompletion { error in
                    if let error = error {
                        // An error happened.
                        print(error)
                    } else {
                        // Account deleted.
                        print("Account deleted")
                    }
                }
            }
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...

    }
    

    @IBAction func loginButtonTouchUpInside(sender: AnyObject) {
        // Google Signin

        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func logoutButtonTouchUpInside(sender: AnyObject) {
        // Google SingOut
        
        loginStatusLabel.alpha = 0.0
        gettingDataActivityIndicator.stopAnimating()
        
        GIDSignIn.sharedInstance().signOut()
        
        let user = FIRAuth.auth()?.currentUser
        user?.deleteWithCompletion { error in
            if let error = error {
                // An error happened.
                print(error)
            } else {
                // Account deleted.
                print("Account deleted")
            }
        }

        try! FIRAuth.auth()!.signOut()
        
        loginButton.enabled = true
        logoutButton.enabled = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userEmailAddress")
        defaults.removeObjectForKey("studentName")
        defaults.removeObjectForKey("studentHomeroom")
        defaults.removeObjectForKey("studentNumber")
        defaults.removeObjectForKey("studentPhoto")
        defaults.removeObjectForKey("studentSchedule")
        
        print("Logged out")
    }
    
    
    
    // function to get back all the students classes
    func getStudentScheduleFromDatabase(studentNumber: Int, onCompletion: [SchoolClass] -> ()) {
        //getStudentScheduleFromDatabase(212649)
        // now need to get the schedule info from Chris's database
        
        var studentSchedule : [SchoolClass] = []
        // could not get this working for some reason!!!!
        //var studentSchedule : StudentSchedule
        
        let studentScheduleRequestURL = NSURL (string: "https://my.mths.ca/patrick/mths_ios/student_schedule_json.php?sn="+String(studentNumber))
        let studentScheduleURLRequest = NSURLRequest(URL: studentScheduleRequestURL!)
        let studentScheduleSession = NSURLSession.sharedSession()
        let studentScheduleTask = studentScheduleSession.dataTaskWithRequest(studentScheduleURLRequest, completionHandler: { (studentScheduleData, studentScheduleResponse, studentScheduleError) in
            guard let scheduleResponseData = studentScheduleData else {
                print("Error: did not receive data")
                
                return
            }
            guard studentScheduleError == nil else {
                print("error calling GET on /posts/1")
                
                return
            }
            
            do {
                let studentScheduleJSONData = try NSJSONSerialization.JSONObjectWithData(scheduleResponseData, options: .MutableContainers) as! NSArray
                
                print("Data retrieved from database")
                
                if studentScheduleJSONData.count > 0 {
                    // Loop through Json objects
                    for singleClass in studentScheduleJSONData {
                        if var item = singleClass as? [String: AnyObject] {
                            let aSingleClass = SchoolClass(
                                semester: String(item["semester"]!),
                                period: String(item["period"]! as! String),
                                course: String(item["course"]!),
                                room: String(item["room"]!),
                                teacher: String(item["teacher"]!))
                            //print(aSingleClass)
                            studentSchedule.append(aSingleClass)
                            
                        }
                    }
                    //print(studentSchedule)
                    onCompletion(studentSchedule)
                }
                
            } catch {
                // handle error
            }
        })
        
        studentScheduleTask.resume()
        
        
        //return studentSchedule
    }
    
    // function to get back student's photo
    func getStudentPhotoFromDatabase(studentNumber: Int, onCompletion: UIImage -> ()) {
        //getStudentScheduleFromDatabase(212649)
        // now need to get the photo info from Chris's database
        
        let studentPhotoRequestURL = NSURL (string: "https://my.mths.ca/photos/" + String(studentNumber) + ".JPG")
        let studentPhotoURLRequest = NSURLRequest(URL: studentPhotoRequestURL!)
        let studentPhotoSession = NSURLSession.sharedSession()
        var studentPhoto : UIImage = UIImage(named: "MTHS_Logo.jpg")!
        
        let studentPhotoTask = studentPhotoSession.dataTaskWithRequest(studentPhotoURLRequest, completionHandler: { (data, response, error) in
            guard let responseData = data else {
                //print("Error: did not receive data")
                self.errorDuringSigningProcess("Error: did not receive data")
                
                return
            }
            guard error == nil else {
                //print("error calling GET on /posts/1")
                self.errorDuringSigningProcess("error calling GET on /posts/1")
                
                return
            }
            
            do {
                //get image
                let getPhoto = NSData(contentsOfURL: studentPhotoRequestURL!)
                //print(getPhoto)
                if getPhoto == nil {
                    // just leave the current generic MTHS logo as the photo
                } else {
                    studentPhoto = UIImage(data: getPhoto!)!
                }
                
                onCompletion(studentPhoto)
                
            } catch {
                // handle error
                print ("An error with the student phtoto")
            }
            
        })
        studentPhotoTask.resume()
    }
    
    /*
    // function to get back all the student's fees
    func getStudentFeesFromDatabase(studentNumber: Int, onCompletion: [StudentFee] -> ()) {
        //getStudentFeesFromDatabase(12014)
        // now need to get the schedule info from Chris's database
        
        var studentFees : [StudentFee] = []
        // could not get this working for StudentFees class for some reason!!!!

        
        // need to create this.
        let studentScheduleRequestURL = NSURL (string: "https://my.mths.ca/patrick/mths_ios/student_schedule_json.php?sn="+String(studentNumber))
        let studentScheduleURLRequest = NSURLRequest(URL: studentScheduleRequestURL!)
        let studentScheduleSession = NSURLSession.sharedSession()
        let studentScheduleTask = studentScheduleSession.dataTaskWithRequest(studentScheduleURLRequest, completionHandler: { (studentScheduleData, studentScheduleResponse, studentScheduleError) in
            guard let scheduleResponseData = studentScheduleData else {
                print("Error: did not receive data")
                
                return
            }
            guard studentScheduleError == nil else {
                print("error calling GET on /posts/1")
                
                return
            }
            
            do {
                let studentScheduleJSONData = try NSJSONSerialization.JSONObjectWithData(scheduleResponseData, options: .MutableContainers) as! NSArray
                
                print("Data retrieved from database")
                
                if studentScheduleJSONData.count > 0 {
                    // Loop through Json objects
                    for singleClass in studentScheduleJSONData {
                        if var item = singleClass as? [String: AnyObject] {
                            let aSingleClass = SchoolClass(semester: String(item["semester"]!),
                                period: Int(item["period"]! as! String),
                                course: String(item["course"]!),
                                room: String(item["room"]!),
                                teacher: String(item["teacher"]!))
                            //print(aSingleClass)
                            studentSchedule.append(aSingleClass)
                            
                        }
                    }
                    //print(studentSchedule)
                    onCompletion(studentSchedule)
                }
                
            } catch {
                // handle error
            }
        })
     
        studentScheduleTask.resume()
        
        
        //return studentSchedule
    }
 */

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
