//
//  SettingTrainController.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/03/07.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit
import Foundation

class SettingTrainController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    var info: ViewController.TrainInfo?
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = info?.station.count{
            return count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainCell", for: indexPath)
        cell.textLabel?.text = info?.station[indexPath.row].StationTitle.ja
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let station = info?.station[indexPath.row]{
            prepare(station_name: station.station, st_janame: station.StationTitle.ja)
        }
        
    }
    
    func prepare(station_name: String, st_janame: String){
        let nav = self.navigationController
        let precontroller = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! DeptureNaviController
        //precontroller.movefromSetTrain(railway_name: railway_name)
        precontroller.destination_name.setTitle(st_janame, for: .normal)
        _ = navigationController?.popViewController(animated: true)
    }

}
