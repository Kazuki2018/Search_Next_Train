//
//  SettingStationController.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/03/07.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit

class SettingStationController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    @IBOutlet weak var tableView: UITableView!
    
    var StationList: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath)
        cell.textLabel?.text = StationList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        set_station(stnum: indexPath.row)
    }
    
    func set_station(stnum: Int){
        let nav = self.navigationController
        let precontroller = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! ViewController
        //
        //precontroller.SettingStation(stnum: stnum)
        _ = navigationController?.popViewController(animated: true)
    }
}
