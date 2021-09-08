//
//  ListViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    @IBAction func logoutBbiPressed(_ sender: Any) {
        logout()
    }
    @IBAction func refreshButtonPressed(_ sender: Any) {
        updateList()
    }
    @IBAction func pinButtonPressed(_ sender: Any) {
        pinMyLocation()
    }
}

// MARK: TableView Delegate & Data Source
extension ListViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityClient.Auth.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCellID")!

        let student = UdacityClient.Auth.students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "icon_pin")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let student = UdacityClient.Auth.students[indexPath.row]
        openURLString(student.mediaURL)
    }
}

// MARK: Helpers
extension ListViewController {
    func updateList() {
        updateStudentsOnTheMap() {
            (success, error) in
            
            if success {
                self.tableView.reloadData()
            } else {
            }
        }
    }
}
