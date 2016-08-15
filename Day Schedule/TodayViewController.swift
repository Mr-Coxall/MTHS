//
//  TodayViewController.swift
//  Day Schedule
//
//  Created by Patrick Coxall on 2016-08-14.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var dayScheduleLabel: UILabel!
    
    // the day schedule Global variable
    // not sure how to make an empty array of dictionaries!!
    var daySchedule: [Dictionary<String, String>] =
        [["day":"2000-01-01","HS_day":"0","7_and_8_day":"0","type":"regular"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        // load the day schedule JSON file into memory
        if let path = NSBundle.mainBundle().pathForResource("day_schedule", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    //let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let jsonResult: NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let currentDate = NSDate()
                    print(currentDate)
                    
                    for singleDay in jsonResult {
                        daySchedule.append(singleDay as! Dictionary<String, String>)
                        let dayAsString = singleDay["day"] as? String
                        let day = dateFormatter.dateFromString(dayAsString!)
                        //print(day!)
                        if day?.compare(currentDate) == NSComparisonResult.OrderedSame {
                            //print (day)
                            //print ("Got it")
                        }
                        
                        let order = NSCalendar.currentCalendar().compareDate(currentDate, toDate: day!, toUnitGranularity: .Day)
                        
                        
                        switch order {
                        case .OrderedDescending:
                            let x = 0
                            //print("DESCENDING")
                        case .OrderedAscending:
                            //print("ASCENDING")
                            let y = 0
                        case .OrderedSame:
                            print("SAME")
                            print(day!)
                        }
                    }
                    
                } catch {
                    print("Error")
                }
            } catch {
                print("Error")
            }
        }
        
        // update the widget label
        dayScheduleLabel.text = "Hello, World!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
