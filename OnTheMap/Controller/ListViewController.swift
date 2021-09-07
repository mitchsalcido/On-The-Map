//
//  ListViewController.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        logout()
    }
}

extension ListViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityClient.Auth.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCellID")!

        let student = UdacityClient.Auth.students[indexPath.row]
        cell.textLabel?.text = "\(student.lastName), \(student.firstName)"
        return cell
    }
}
