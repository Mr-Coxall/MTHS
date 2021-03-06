
//
//  MyScheduleViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class MyScheduleViewController: UITableViewController {
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var studentArrayOfClasses = [[String: String]()]
    var tableRowStringArray: [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // check if you are currently logged in and have data stored locally
        if let studentName = defaults.stringForKey("studentName") {
            // logged in
            print("Loged in as:" + studentName)
            
            let studentHomeroom = defaults.stringForKey("studentHomeroom")
            let studentAnyObjectOfClasses = defaults.objectForKey("studentSchedule")
            studentArrayOfClasses = (studentAnyObjectOfClasses as! NSArray) as! Array
            
            // it is different if you are in HS or 7&8
            let lengthOfHomeroom = studentHomeroom!.characters.count
            //print(lengthOfHomeroom)
            
            if lengthOfHomeroom != 5  {
                // 7&8 homeroom
                
                for tempClass in studentArrayOfClasses {
                    //print(tempClass)
                    switch UIDevice.currentDevice().userInterfaceIdiom {
                    case .Phone:
                        // It's an iPhone
                        tableRowStringArray.append("Day: " + tempClass["day"]! +
                            " Period: " + tempClass["period"]! + "\r\n" +
                            "Course: " + tempClass["course"]!)
                        self.tableView.rowHeight = 75.0
                    case .Pad:
                        // It's an iPad
                        tableRowStringArray.append("Day: " + tempClass["day"]! +
                            " Period: " + tempClass["period"]! + "\r\n" +
                            "Course: " + tempClass["course"]!)
                    default:
                        // Uh, oh! What could it be?
                        print("You are in trouble!!")
                    }
                    
                }
                
            } else {
                // HS homeroom

                for tempClass in studentArrayOfClasses {
                    //print(tempClass)
                    switch UIDevice.currentDevice().userInterfaceIdiom {
                    case .Phone:
                        // It's an iPhone
                        tableRowStringArray.append("Semester: " + tempClass["semester"]! +
                            " Period: " + tempClass["period"]! + "\r\n" +
                            "Course: " + tempClass["course"]! +
                            " Room: " + tempClass["room"]! + "\r\n" +
                            "Teacher: " + tempClass["teacher"]!)
                        self.tableView.rowHeight = 75.0
                    case .Pad:
                        // It's an iPad
                        tableRowStringArray.append("Semester: " + tempClass["semester"]! +
                            " Period: " + tempClass["period"]! +
                            " Course: " + tempClass["course"]! +
                            " Room: " + tempClass["room"]! +
                            " Teacher: " + tempClass["teacher"]!)
                    default:
                        // Uh, oh! What could it be?
                        print("You are in trouble!!")
                    }
                    
                }
            }

        } else {
            // NOT logged in !!
            
            tableRowStringArray.append("No classes assigned yet.")
        }
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // for updating the table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRowStringArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // make it multi-lines
        cell.textLabel?.numberOfLines = 3
        //self.tableView.rowHeight = 75.0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        cell.textLabel?.text = tableRowStringArray[indexPath.row]
    
        return cell
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
