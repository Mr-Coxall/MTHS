
//
//  MyScheduleViewController.swift
//  MTHS
//
//  Created by Patrick Coxall on 2016-07-11.
//  Copyright © 2016 Patrick Coxall. All rights reserved.
//

import UIKit

class MyScheduleViewController: UITableViewController {
    
    var defaults = UserDefaults.standard
    var studentArrayOfClasses = [[String: String]()]
    var tableRowStringArray: [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // check if you are currently logged in and have data stored locally
        if let studentName = defaults.string(forKey: "studentName") {
            // logged in
            print("Loged in as:" + studentName)
            
            let studentHomeroom = defaults.string(forKey: "studentHomeroom")
            let studentAnyObjectOfClasses = defaults.object(forKey: "studentSchedule")
            studentArrayOfClasses = (studentAnyObjectOfClasses as! NSArray) as! Array
            
            // it is different if you are in HS or 7&8
            let lengthOfHomeroom = studentHomeroom!.characters.count
            //print(lengthOfHomeroom)
            
            if lengthOfHomeroom != 5  {
                // 7&8 homeroom
                
                for tempClass in studentArrayOfClasses {
                    //print(tempClass)
                    switch UIDevice.current.userInterfaceIdiom {
                    case .phone:
                        // It's an iPhone
                        tableRowStringArray.append("Day: " + tempClass["day"]! +
                            " Period: " + tempClass["period"]! + "\r\n" +
                            "Course: " + tempClass["course"]!)
                        self.tableView.rowHeight = 75.0
                    case .pad:
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
                    switch UIDevice.current.userInterfaceIdiom {
                    case .phone:
                        // It's an iPhone
                        tableRowStringArray.append("Semester: " + tempClass["semester"]! +
                            " Period: " + tempClass["period"]! + "\r\n" +
                            "Course: " + tempClass["course"]! +
                            " Room: " + tempClass["room"]! + "\r\n" +
                            "Teacher: " + tempClass["teacher"]!)
                        self.tableView.rowHeight = 75.0
                    case .pad:
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

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // for updating the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRowStringArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // make it multi-lines
        cell.textLabel?.numberOfLines = 3
        //self.tableView.rowHeight = 75.0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        cell.textLabel?.text = tableRowStringArray[(indexPath as NSIndexPath).row]
    
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
