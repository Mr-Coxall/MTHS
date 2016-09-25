//
//  SchoolTimetablesViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class SchoolTimetablesViewController: UIViewController {

    @IBOutlet weak var schoolTimetableWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // load school timetable
        let url = Bundle.main.url(forResource: "School Timetables", withExtension:"html")
        let requestObj = URLRequest(url: url!);
        schoolTimetableWebView.loadRequest(requestObj);
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
