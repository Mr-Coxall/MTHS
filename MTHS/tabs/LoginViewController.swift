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
    
    // variables
    //var credential : FIRAuthCredential

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        // check if user is logged in
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userEmailAddress = defaults.stringForKey("userEmailAddress") {
            print("User logger in:")
            print(userEmailAddress)
            loginButton.enabled = false
            logoutButton.enabled = true
        } else {
            loginButton.enabled = true
            logoutButton.enabled = false
        }
    }
    
    // Google Signin

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
        //
        
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
                }

                
                print("Logged in")
                
                // now need to get the user info from Chris's database
                
                let studentInfoRequestURL = NSURL (string: "https://my.mths.ca/patrick/mths_ios/student_json.php?email="+fullEmail!)
                let studentInfoURLRequest = NSURLRequest(URL: studentInfoRequestURL!)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(studentInfoURLRequest, completionHandler: { (data, response, error) in
                    guard let responseData = data else {
                        print("Error: did not receive data")
                        let alert = UIAlertController(title: "Alert", message: "Unable to get your student data, please contact the librarian.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        return
                    }
                    guard error == nil else {
                        print("error calling GET on /posts/1")
                        print(error)
                        let alert = UIAlertController(title: "Alert", message: "Unable to get your student data, please contact the librarian.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        return
                    }
                    
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(responseData, options: .MutableContainers) as! NSArray
                        // Do Stuff
                        print(jsonData)
                        
                        if jsonData.count==1 {
                            // if there is a single record
                            if let item = jsonData[0] as? [String: AnyObject] {
                                let studentName = item["name"] as? String
                                let studentHomeroom = item["homeroom"] as? String
                                let studentNumberAsString = item["student_number"] as? String
                                
                                guard let studentNumber:Int = Int(studentNumberAsString!)! else {
                                    print("Cannot convert student number to int")
                                    let alert = UIAlertController(title: "Alert", message: "Unable to get your student data, please contact the librarian.", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    
                                    return
                                }

                                // add info to user defaults
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setObject(studentName!, forKey: "studentName")
                                defaults.setObject(studentHomeroom!, forKey: "studentHomeroom")
                                defaults.setObject(studentNumber, forKey: "studentNumber")
                                
                                // finally done, you have good basic student info
                                //change over the login buttons
                                self.loginButton.enabled = false
                                self.logoutButton.enabled = true
                            } else {
                                print("error getting student data")
                                let alert = UIAlertController(title: "Alert", message: "Error getting your student data, please contact the librarian.", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            
                        } else {
                            // no data for that student returned
                            print("No student data")
                            let alert = UIAlertController(title: "Alert", message: "Error getting your student data, please contact the librarian.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    } catch {
                        // handle error
                    }

                })
                
                task.resume()
                
            } else {
                // not the correct domain
                print("You are not using the correct email address")
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
