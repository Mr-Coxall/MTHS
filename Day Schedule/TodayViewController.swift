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
                        
                        if order == NSComparisonResult.OrderedSame {
                            print(day!)
                            // this is today, so update today widget label
                            
//                            let hsDayAsString = singleDay["HS_day"] as? String
//                            let sevenAnd8DayAsString = singleDay["7_and_8_day"] as? String
//                            
//                            let hsDayAsInt = Int(hsDayAsString!)
//                            let sevenAnd8DayAsInt = Int(sevenAnd8DayAsString!)
//                            
//                            var widgetString: String
//                            if hsDayAsInt != nil && sevenAnd8DayAsInt != nil{
//                                // just 2 regular day numbers
//                                
//                                widgetString = "Day \(hsDayAsInt!) - HS & Day \(sevenAnd8DayAsInt!) - 7 & 8"
//                            }
//                            else if hsDayAsInt == nil && sevenAnd8DayAsInt != nil {
//                                // HS has exams
//                                
//                                widgetString = "\(hsDayAsString!) & Day \(sevenAnd8DayAsInt!) - 7 & 8"
//                            } else {
//                                // both are text, so just show 1
//                                
//                                widgetString = hsDayAsString!
//                            }
                            
                            // 7&8 have moved to Days of the week, so we no longer need the above
                            let hsDayAsString = singleDay["HS_day"] as? String
                            let hsDayAsInt = Int(hsDayAsString!)
                            let widgetString = "HS - Day \(hsDayAsInt!)"
                            
                            dayScheduleLabel.text = widgetString
                            
                            // since we are done, leave the for loop
                            break
                        }
                        
                    }
                    
                } catch {
                    print("Error")
                }
            } catch {
                print("Error")
            }
        }
        
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
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
