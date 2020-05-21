//
//  ViewController.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/03/06.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    @IBOutlet weak var StationSetting: UIButton!
    
    var Info: TrainInfo?
    var Stlist: [String] = []
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDepartNavigation"{
            let Dn: DeptureNaviController = (segue.destination as? DeptureNaviController)!
            Dn.info = self.Railway_name[0]
            Dn.nowstation_index = get_nowstation().index
            if let t = get_nowstation(){
                print("t.station", t.station)
                Dn.nowstation = t.station
                Dn.nowstation_name = t.StationTitle.ja
            }
            
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func train_button(_ sender: Any) {
        print("train_search button clicked")
        self.searchTrain(st_name: StationSetting.currentTitle!)
    }
    var resultTrain: [ItemTrain] = []
    struct ItemTrain: Codable {
        let stationName : String?
        let railway: String?
        let operater: String?
        let stationCode: String?
        let Timetable: [String]?
        
        enum CodingKeys: String, CodingKey {
            case stationName = "owl:sameAs"
            case railway = "odpt:railway"
            case operater = "odpt:Operator"
            case stationCode = "odpt:stationCode"
            case Timetable = "odpt:stationTimetable"
        }
    }
    var train_name: String = ""
    func searchTrain(st_name: String){
        guard let keyword_encode = st_name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string: "https://api-tokyochallenge.odpt.org/api/v4/odpt:Station?dc:title=" + keyword_encode + "&odpt:operator=odpt.Operator:JR-East&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004") else {
            return
        }
        print(req_url)
        
        
        let req = URLRequest(url: req_url)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error) in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                self.resultTrain = try decoder.decode([ItemTrain].self, from: data!)
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultTrain.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainCell", for: indexPath)
        cell.textLabel?.text = resultTrain[indexPath.row].railway
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        train_name = resultTrain[indexPath.row].railway!
        let train_timetable = resultTrain[indexPath.row]
        
    }
    
    struct TrainInfo: Codable {
        var train_name: Railway
        var station: [Stations]
        var railway: String
        var ascendingRailDirection:String?
        var descendingRailDirection:String?
        struct Railway: Codable{
            var en: String
            var ja: String
        }
        
        struct Stations: Codable {
            var index: Int
            var station: String
            var StationTitle: Railway
            
            enum CodingKeys: String, CodingKey {
                case index = "odpt:index"
                case station = "odpt:station"
                case StationTitle = "odpt:stationTitle"
            }
            
        }
        
        enum CodingKeys: String, CodingKey {
            case railway = "owl:sameAs"
            case train_name = "odpt:railwayTitle"
            case station = "odpt:stationOrder"
            case ascendingRailDirection = "odpt:ascendingRailDirection"
            case descendingRailDirection = "odpt:descendingRailDirection"
        }
    }
    
    var Railway_name: [TrainInfo] = []
    
    func get_traininfo(train_name: String){
        guard let req_url = URL(string: "https://api-tokyochallenge.odpt.org/api/v4/odpt:Railway?odpt:operator=odpt.Operator:JR-East&owl:sameAs=" +  train_name +  "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004") else {
            return
        }
        print(req_url)
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                self.Railway_name = try decoder.decode([TrainInfo].self, from: data!)
                print(self.Railway_name)
                self.performSegue(withIdentifier: "goDepartNavigation", sender: nil)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    @IBAction func displayinfo_button(_ sender: Any) {
        get_traininfo(train_name: train_name)
    }
    
    func get_nowstation() -> TrainInfo.Stations!{
        let Info = self.Railway_name[0]
        for t in Info.station{
            if(t.StationTitle.ja == StationSetting.currentTitle){
                return t
            }
        }
        return nil
    }
    
}
