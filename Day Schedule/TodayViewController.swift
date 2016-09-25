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
        if let path = Bundle.main.path(forResource: "day_schedule", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    //let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let jsonResult: NSArray = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let currentDate = Date()
                    print(currentDate)
                    
                    for singleDay in jsonResult {
                        daySchedule.append(singleDay as! Dictionary<String, String>)
                        let dayAsString = singleDay["day"] as? String
                        let day = dateFormatter.date(from: dayAsString!)
                        //print(day!)
                        if day?.compare(currentDate) == ComparisonResult.orderedSame {
                            //print (day)
                            //print ("Got it")
                        }
                        
                        let order = (Calendar.current as NSCalendar).compare(currentDate, to: day!, toUnitGranularity: .day)
                        
                        if order == ComparisonResult.orderedSame {
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
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.newData)
    }
    
}
