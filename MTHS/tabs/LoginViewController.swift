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
        
        print ("In view Controller")
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
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        print ("In view Controller")
        
        try! FIRAuth.auth()!.signOut()
    }
    

    @IBAction func loginButtonTouchUpInside(sender: AnyObject) {
        // Google Signin

        GIDSignIn.sharedInstance().signIn()
        loginButton.enabled = false
        logoutButton.enabled = true
        
        print("Logged in")
    }
    
    @IBAction func logoutButtonTouchUpInside(sender: AnyObject) {
        // Google SingOut
        GIDSignIn.sharedInstance().signOut()
        loginButton.enabled = true
        logoutButton.enabled = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userEmailAddress")
        
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
