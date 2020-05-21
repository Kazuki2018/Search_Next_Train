//
//  SationController.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/08/14.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit

class SationController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    public var Station: Array<String> = Array(repeating:"", count: 1518)
    
    public var station_name: Array<String> = Array()
    
    var resultStationList : [(kanji:String, gana: String, english: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadcsvfile()
        // Do any additional setup after loading the view.
        StationSearch.delegate = self
        StationSearch.placeholder = "出発駅を入力してください"
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    
    @IBOutlet weak var StationSearch: UISearchBar!
    
    @IBAction func GPSSearchButton(_ sender: Any) {
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchWord = searchBar.text {
            searchStation(st_name: searchWord)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
    }
    
    func loadcsvfile(){
        do{
            if let csvPath = Bundle.main.path(forResource: "Stations_utf8", ofType: "csv")
            {
                let csvData = try String(contentsOfFile: csvPath, encoding:String.Encoding.utf8)
                //改行コードが\n一つになるようにします
                var lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
                lineChange = lineChange.replacingOccurrences(of: "\n\n", with: "\n")
                //"\n"の改行コードで区切って、配列csvArrayに格納する
                Station = lineChange.components(separatedBy: "\n")
                for data in Station{
                    station_name += data.components(separatedBy: ",")
                }
                
            }
        } catch {
            print(error)
        }
    }
    
    func searchStation(st_name: String){
        self.resultStationList.removeAll()
        let count = st_name.count
        for i in stride(from: 0, to: 4550, by: 3){
            let par_name = station_name[i].prefix(count)
            let par_name2 = station_name[i+1].prefix(count)
            
            if par_name == st_name || par_name2 == st_name{
                resultStationList.append((station_name[i],station_name[i+1],station_name[i+2]))
            }
        }
        self.tableView.reloadData()
        for p in resultStationList{
            print(p)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultStationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath)
        cell.textLabel?.text = resultStationList[indexPath.row].kanji + "  " + resultStationList[indexPath.row].gana
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        StationSearch.text = resultStationList[indexPath.row].kanji
        if let p = StationSearch.text {
            pre(n: p)
        }
 
    }
    
    func pre(n: String){
        let nav = self.navigationController
        let precontroller = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! ViewController
        precontroller.StationSetting.setTitle(n, for: .normal)
        precontroller.StationSetting.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        
        
        //precontroller.presetting(name: n)
        _ = navigationController?.popViewController(animated: true)
    }
}
