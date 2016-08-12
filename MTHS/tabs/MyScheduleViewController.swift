
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
            
            let studentAnyObjectOfClasses = defaults.objectForKey("studentSchedule")
            studentArrayOfClasses = (studentAnyObjectOfClasses as! NSArray) as! Array
            
            for tempClass in studentArrayOfClasses {
                //print(tempClass)
                switch UIDevice.currentDevice().userInterfaceIdiom {
                case .Phone:
                    // It's an iPhone
                    tableRowStringArray.append("Semester: " + tempClass["semester"]! +
                        " Period: " + tempClass["period"]! + "\r\n" +
                        "Course: " + tempClass["course"]! +
                        " Room: " + tempClass["room"]!)
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
