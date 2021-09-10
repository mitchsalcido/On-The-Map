//
//  ListViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//
/*
 About ListViewController:
 Handle presentation of student locations in a list (tableView). Includes logout, refresh functionality
 */

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // view object
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update tableView
        tableView.reloadData()
    }
    
    // log out of app
    @IBAction func logoutBbiPressed(_ sender: Any) {
        logout()
    }
    
    // refresh studend location data
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refeshStudentData()
    }
    
    // invoke pin location...post user location
    @IBAction func pinButtonPressed(_ sender: Any) {
        pinMyLocation()
    }
}

// MARK: TableView Delegate & Data Source
extension ListViewController {
    
    // number of row is count of students on the map
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityAPI.students.count
    }
    
    // retrieve cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCellID")!

        // populate cell with student data
        let student = UdacityAPI.students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "icon_pin")
        return cell
    }
    
    // select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
         When cell tapped, present medial URL
         */
        
        // deselct
        tableView.deselectRow(at: indexPath, animated: true)
        
        // open media URL
        let student = UdacityAPI.students[indexPath.row]
        openURLString(student.mediaURL)
    }
}

// MARK: Helpers
extension ListViewController {
    
    // refresh list(tableView)
    func refeshStudentData() {
        /*
         Retrieve(upadate) students on the map, update map
         */
        
        // get updated students
        updateStudentsOnTheMap() {
            (success, error) in
            
            if success {
                // good update. Reload tableView with new student data
                self.tableView.reloadData()
            } else {
                // bad update. Present error with alert
                self.failedGetStudents(error)
            }
        }
    }
}
