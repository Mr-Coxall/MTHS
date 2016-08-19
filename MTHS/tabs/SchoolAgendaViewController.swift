//
//  SchoolAgendaViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class SchoolAgendaViewController: UIViewController {

    @IBOutlet weak var schoolAgendaWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // load school timetable
        let url = NSBundle.mainBundle().URLForResource("Student Handbook", withExtension:"pdf")
        let requestObj = NSURLRequest(URL: url!)
        schoolAgendaWebView.loadRequest(requestObj)
        // make it full screen
        schoolAgendaWebView.scalesPageToFit = true
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
