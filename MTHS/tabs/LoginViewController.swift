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
        
        // make the Login Status label invisible
        gettingDataActivityIndicator.hidesWhenStopped = true
        gettingDataActivityIndicator.stopAnimating()
        
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
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
                self.loginStatusLabel.text = "Getting your student information from database."
                
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
                        self.loginStatusLabel.text = "Pasring your data retrieved from database."
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
                                self.loginStatusLabel.text = "Saving your student data."
                                print("Saving to user defaults")
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setObject(studentName, forKey: "studentName")
                                defaults.setObject(studentHomeroom!, forKey: "studentHomeroom")
                                defaults.setObject(studentNumber, forKey: "studentNumber")
                                
                                // now get the student photo
                                self.loginStatusLabel.text = "Getting your student photo."
                                
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
                                        studentPhoto = UIImage(data: getPhoto!)!
                                        print(studentPhoto)
                                        defaults.setObject(UIImagePNGRepresentation(studentPhoto), forKey: "studentPhoto")
                                        print("Saved photo")
                                        
                                        // test
                                        
                                        let bgImage = UIImageView(image: studentPhoto)
                                        bgImage.frame = CGRectMake(0,0,200,300)
                                        self.view.addSubview(bgImage)
                                    
                                    } catch {
                                        // handle error
                                        print ("An error with the student phtoto")
                                    }
                                    
                                })
                                studentPhotoTask.resume()
                                
                                

                            
                                    
                                
                                
                                
                                
                                
                                // finally done, you have good basic student info
                                //change over the login buttons
                                self.loginStatusLabel.text = "Logged in as \(studentName)"
                                self.loginButton.enabled = false
                                self.logoutButton.enabled = true
                                
                                // all done
                                self.gettingDataActivityIndicator.stopAnimating()
                                print("All done getting student data")
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
        
        print("Logged out")
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
