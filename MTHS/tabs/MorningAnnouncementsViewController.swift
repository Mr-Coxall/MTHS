//
//  MorningAnnouncementsViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class MorningAnnouncementsViewController: UIViewController {

    @IBOutlet weak var morningAnnouncementsWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // load morning announcements
        let url = URL (string: "https://mother-teresa-hs.blogspot.ca/?m=1");
        let requestObj = URLRequest(url: url!);
        morningAnnouncementsWebView.loadRequest(requestObj);
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
