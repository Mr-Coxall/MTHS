//
//  SchoolCalendarViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class SchoolCalendarViewController: UIViewController {

    @IBOutlet weak var schoolCalendarWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // load school calendar
        let url = NSURL (string: "https://calendar.google.com/calendar/embed?src=ocsb.ca_sdch4911okio03csdkuaf27beg@group.calendar.google.com&ctz=America/Toronto&pvttk=a3b984a811faad9e768b6735cd65a7bd&mode=AGENDA&showDate=0&showPrint=0&showTabs=0&showCalendars=0&showTz=0&wkst=1&showTitle=0%22");
        let requestObj = NSURLRequest(URL: url!);
        schoolCalendarWebView.loadRequest(requestObj);
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
