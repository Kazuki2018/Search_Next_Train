//
//  DeptureNaviController.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/03/10.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit
import CalculateCalendarLogic

class DeptureNaviController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var train_icon: UIImageView!
    @IBOutlet weak var station_name: UILabel!
    @IBOutlet weak var railway_name: UILabel!
    
    @IBOutlet weak var Tr_Info: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image_name = return_number_icon(name: self.info?.train_name.ja)
        if let train_image =  UIImage(named: image_name){
            let image = resizeUIImageByWidth(image: train_image, width: 30)
            train_icon.image = image
        }
        arrive_train_table0.delegate = self
        arrive_train_table0.dataSource = self
        arrive_train_table1.delegate = self
        arrive_train_table1.dataSource = self
        railway_name!.text = info?.train_name.ja
        station_name!.text = nowstation_name
        display_trainInformation()
        setDirection()
        getTrainposition(dr_flag: 0,direction: descend_direction)
        getTrainposition(dr_flag: 1, direction: ascend_direction)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPathForSelectedRow = arrive_train_table0.indexPathForSelectedRow {
            arrive_train_table0.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        if let indexPathForSelectedRow = arrive_train_table1.indexPathForSelectedRow {
            arrive_train_table1.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    var tr_status: [TrainStatus] = []
    var info: ViewController.TrainInfo?
    var descend_direction: String = ""
    var ascend_direction: String = ""
    @IBOutlet weak var descend_Direction_label: UILabel!
    @IBOutlet weak var ascend_Direction_label: UILabel!
    
    //API用
    var train_name: String = ""
    
    @IBOutlet weak var arrive_train_table0: UITableView!
    @IBOutlet weak var arrive_train_table1: UITableView!
    
    var nowstation_index: Int = 0
    var nowstation_name: String = ""
    var st_order: [ViewController.TrainInfo.Stations] = []
    var arrivalTrain0: [TrainPosition] = []
    var arriveTrain0: [train_data] = []
    var sort_arriveTrain0: [train_data] = []
    var arrivalTrain1: [TrainPosition] = []
    var arriveTrain1: [train_data] = []
    var sort_arriveTrain1: [train_data] = []
    var sort_arriveTrain: [[train_data]] = []
    var station: [Station_Data] = []
    var train_position0: [TrainPosition] = []
    var train_position1: [TrainPosition] = []
    var select_row_num: Int = 0
    
    struct TrainStatus: Codable {
        var info_text: Language?
        var train_status: Language?
        struct Language: Codable{
            var ja: String?
            var en: String?
        }
        enum CodingKeys: String, CodingKey {
            case info_text = "odpt:trainInformationText"
            case train_status = "odpt:trainInformationStatus"
        }
    }
    
    struct TrainPosition: Codable{
        var fromStation: String?
        var toStation: String?
        var trainNumber: String?
        var delay: Int
        var trainType: String?
        enum CodingKeys: String, CodingKey {
            case fromStation = "odpt:fromStation"
            case toStation = "odpt:toStation"
            case trainNumber = "odpt:trainNumber"
            case delay = "odpt:delay"
            case trainType = "odpt:trainType"
        }
    }
    
    struct Timetable: Codable{
        var trainTimetableObject: Array<Dictionary<String, String>> = []
        var destinationStation: [String]?
        var nextTimetable: [String]?
        enum CodingKeys: String, CodingKey {
            case trainTimetableObject = "odpt:trainTimetableObject"
            case destinationStation = "odpt:destinationStation"
            case nextTimetable = "odpt:nextTrainTimetable"
        }
    }
    
    struct train_data{
        var obj: Array<Dictionary<String, String>> = []
        var trainType: String?
        var schedule: String?
        var time: Int
        var delay: Int?
        var destination: [String]?
        var nextTimetable: [String]?
    }
    
    struct Station_Data: Codable{
        var station_object: Language
        struct Language: Codable{
            var ja: String?
            var en: String?
        }
        enum CodingKeys: String, CodingKey {
            case station_object = "odpt:stationTitle"
        }
    }
    
    struct Direction_Data: Codable{
        var direction_object: Language
        struct Language: Codable{
            var ja: String?
            var en: String?
        }
        enum CodingKeys: String, CodingKey {
            case direction_object = "odpt:railDirectionTitle"
        }
    }
    
    func display_trainInformation(){
        Tr_Info.titleLabel?.numberOfLines = 0
        if let rail = info?.railway{
            guard let req_url = URL(string: "https://api-tokyochallenge.odpt.org/api/v4/odpt:TrainInformation?odpt:railway=" + rail  + "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004") else {
                return
            }
            print(req_url)
            let req = URLRequest(url: req_url)
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: req, completionHandler: {(data, responce, error)in
                session.finishTasksAndInvalidate()
                do {
                    let decoder = JSONDecoder()
                    self.tr_status = try decoder.decode([TrainStatus].self, from: data!)
                    if self.tr_status.isEmpty {
                        self.Tr_Info.setTitle("現在、平常通り運行しています", for: .normal)
                    } else {
                        self.Tr_Info.setTitle(self.tr_status[0].info_text?.ja, for: .normal)
                    }
                } catch {
                    print(error)
                }
            })
            task.resume()
        }
    }
    
    func setDirection(){
        print("start stDirection")
        //descend
        descend_direction = (info?.descendingRailDirection)!
        let _ = define_direction(dr: 1, direction_name: descend_direction)
        //ascend
        ascend_direction = (info?.ascendingRailDirection)!
        define_direction(dr: 0, direction_name: ascend_direction)
    }
    
    func define_direction(dr: Int, direction_name: String){
        print("start difine_direction")
        var d_data: [Direction_Data] = []
        
        guard let req_url = URL(string: "https://api-tokyochallenge.odpt.org/api/v4/odpt:RailDirection?owl:sameAs=" + direction_name + "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004") else {
            return
        }
        print(req_url)
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                d_data = try decoder.decode([Direction_Data].self, from: data!)
                if(dr==0){
                    //Asscending labelを変換
                    self.ascend_Direction_label.text = d_data[0].direction_object.ja
                }else{
                    self.descend_Direction_label.text = d_data[0].direction_object.ja
                }
                
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    
    func getTrainposition(dr_flag: Int, direction: String){
        if let p = info?.railway{
            self.train_name = p
        }
        if let p = info?.station{
            self.st_order = p
        }
        guard let req_url = URL(string: "https://api-tokyochallenge.odpt.org/api/v4/odpt:Train?odpt:railway=" + train_name + "&odpt:railDirection=" + direction + "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004") else {return}
        print(req_url)
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                if dr_flag == 0{
                    self.train_position0 = try decoder.decode([TrainPosition].self, from: data!)
                }else{
                    self.train_position1 = try decoder.decode([TrainPosition].self, from: data!)
                }
                
                self.search_arrivalTrain(direction_flag: dr_flag)
                
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    
    
    func search_arrivalTrain(direction_flag: Int){
        if direction_flag == 0 {
            for i in nowstation_index-1..<st_order.count{
                for j in 0..<train_position0.count{
                    let tostation = train_position0[j].toStation
                    let fromstation = train_position0[j].fromStation
                    //停車中の列車
                    if (tostation == nil) && fromstation == st_order[i].station{
                        arrivalTrain0.append(train_position0[j])
                    }
                    //駅間走行中の列車
                    if i != st_order.count-1{
                        if tostation == st_order[i].station && fromstation == st_order[i+1].station{
                            arrivalTrain0.append(train_position0[j])
                        }
                    }
                }
            }
        } else {
            for i in (0...nowstation_index-1).reversed(){
                for j in 0..<train_position1.count{
                    let tostation = train_position1[j].toStation
                    let fromstation = train_position1[j].fromStation
                    if (tostation == nil) && (fromstation == st_order[i].station){
                        arrivalTrain1.append(train_position1[j])
                    }
                    if i != 0{
                        if tostation == st_order[i].station && fromstation == st_order[i-1].station{
                            arrivalTrain1.append(train_position1[j])
                        }
                    }
                }
            }
        }
        searchTrain(direction_flag: direction_flag)
    }
    
    func searchTrain(direction_flag: Int){
        print("start SearchTrain")
        let date = Date()
        print(date)
        var daytype: String = ""
        //平日：Weekday，休日：SaturdayHoliday
        if(judgeHoliday(date)==true || getWeekIdx(date) == 1 || getWeekIdx(date) == 7){
            daytype = "SaturdayHoliday"
        }else{
            daytype = "Weekday"
        }
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let h_time = formatter.string(from: now as Date)
        if h_time == "0" || h_time == "1" || h_time == "2"{
            if getWeekIdx(date) == 7{
                daytype = "Weekday"
            } else if getWeekIdx(date) == 2{
                daytype = "SaturdayHoliday"
            }
        }
        var i:Int = 0
        
        var arrivalTrain: [TrainPosition] = []
        if direction_flag == 0{
            arrivalTrain = arrivalTrain0
        }else{
            arrivalTrain = arrivalTrain1
        }
        
        for train in arrivalTrain {
            let delay = train.delay
            let train_type = train.trainType
            let separate_railway = train_name.components(separatedBy: ":")
            let t_name = separate_railway[1]
            if let num = train.trainNumber{
                let api_timetable_string = "odpt.TrainTimetable:" + t_name + "." + num + "." + daytype
                self.return_timetableobj(api_string: api_timetable_string, finished: {(isSuccess: Bool, train_table: [Timetable]) in
                    i = i + 1
                    if isSuccess==true{
                        if !train_table.isEmpty{
                            let timetable = train_table[0].trainTimetableObject
                            for time in timetable{
                                let key = "odpt:departureStation"
                                if time[key] != nil && time[key]==self.st_order[self.nowstation_index-1].station{
                                    let departuretime = time["odpt:departureTime"]?.components(separatedBy: ":")
                                    if let dh = departuretime?[0], let dm = departuretime?[1]{
                                        var h = Int(dh)!
                                        let m = Int(dm)!
                                        let d = delay/60
                                        if h>=0 && h<=3 {
                                            h = h + 24
                                        }
                                        let tmp = train_data(obj: train_table[0].trainTimetableObject,  trainType: train_type, schedule: time["odpt:departureTime"], time: 60*h+m+d, delay: d, destination: train_table[0].destinationStation, nextTimetable: train_table[0].nextTimetable)
                                        if direction_flag==0{
                                            self.arriveTrain0.append(tmp)
                                        }else{
                                            self.arriveTrain1.append(tmp)
                                        }
                                        break
                                    }
                                }
                            }
                        }
                        if i==arrivalTrain.count{
                            print("end arrivalTrain")
                            if direction_flag == 0{
                                self.sort_arriveTrain0 = self.arriveTrain0.sorted(by: {$0.time < $1.time})
                                print("direction_flag==0")
                                print(self.sort_arriveTrain0)
                                self.arrive_train_table0.reloadData()
                            }else{
                                self.sort_arriveTrain1 = self.arriveTrain1.sorted(by: {$0.time < $1.time})
                                print("direction_flag==1")
                                print(self.sort_arriveTrain1)
                                self.arrive_train_table1.reloadData()
                            }
                        }
                    }else{
                        print("cannot do")
                    }
                })
            }
        }
    }
    
    func add_nextTimetable(train_item: train_data, return_obj: @escaping (Array<Dictionary<String, String>>)->Void){
        if let table = train_item.nextTimetable{
            print(table)
            self.return_timetableobj(api_string: table[0], finished: {(isSuccess: Bool, train_table:[Timetable]) in
                //self.sort_arriveTrain[i].obj = first_timetable + next_timetable
                if isSuccess == true {return_obj(train_item.obj + train_table[0].trainTimetableObject)}
                else {return_obj(train_item.obj)}
                //print(self.sort_arriveTrain[i].obj)
            })
        }else{
            print("connot find")
            return_obj(train_item.obj)
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            if sort_arriveTrain0.count > 3{
                return 3
            }else{
                return self.sort_arriveTrain0.count
            }
        }else{
            if sort_arriveTrain1.count > 3{
                return 3
            }else{
                return self.sort_arriveTrain1.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:TrainTableViewCell
        var train_source: train_data?
        if tableView.tag == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "trainCell0", for: indexPath) as! TrainTableViewCell
            self.add_nextTimetable(train_item: sort_arriveTrain0[indexPath.row], return_obj: {(tmp: Array<Dictionary<String, String>>) in
                self.sort_arriveTrain0[indexPath.row].obj = tmp
            })
            train_source = sort_arriveTrain0[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "trainCell1", for: indexPath) as! TrainTableViewCell
            self.add_nextTimetable(train_item: sort_arriveTrain1[indexPath.row], return_obj: {(tmp: Array<Dictionary<String, String>>) in
                self.sort_arriveTrain1[indexPath.row].obj = tmp
            })
            train_source = sort_arriveTrain1[indexPath.row]
        }
        
        if let x = train_source?.destination{
            for item in x{
                self.return_station_janame(Station_name: item, finished: {(isSuccess: Bool, ja_name: String) in
                    if isSuccess==true{
                        cell.direction_name!.text = ja_name
                    }else{
                        print("cannot do")
                    }
                })
            }
        }
        if let name = train_source?.trainType{
            cell.traintype_name!.text = return_traintype_janame(TrainType_name: name, lang_flag: 1)
        }
        if let schedule = train_source?.schedule{
            cell.departure_time!.text = schedule
        }
        
        if let d = train_source?.delay{
            
            if d > 0{
                cell.delay!.text = String(d) + "分遅れ"
                cell.delay.textColor = .red
            }else{
                cell.delay!.text = "時刻通り"
                cell.delay.textColor = .blue
            }
        }
        var h: String = ""
        var m: String = ""
        if let time = train_source?.time{
            h = String(time/60)
            m = String(time - (time/60)*60)
        }
        if m.utf8.count == 1{
            m = "0" + m
        }
        let p =  h + ":" + m
        //cell.esimate_time.text = p
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.select_row_num = indexPath.row
        if tableView.tag == 0{
            performSegue(withIdentifier: "goTrainTimetable", sender: 0)
        } else{
            performSegue(withIdentifier: "goTrainTimetable", sender: 1)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTrainTimetable"{
            let St: Train_timetable = (segue.destination as? Train_timetable)!
            St.modalPresentationStyle = .overCurrentContext
            let tagid: Int = sender as! Int
            if tagid == 0{
                St.Traintimetable = self.sort_arriveTrain0[select_row_num].obj
            }else{
                St.Traintimetable = self.sort_arriveTrain1[select_row_num].obj
            }
        } else if segue.identifier == "goset_destination"{
            let Dt: SettingTrainController = (segue.destination as? SettingTrainController)!
            Dt.info = info
        }
    }
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    func return_timetableobj(api_string: String, finished: @escaping (Bool, [Timetable])->Void){
        let url_string = "https://api-tokyochallenge.odpt.org/api/v4/odpt:TrainTimetable?owl:sameAs=" + api_string +  "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004"
        let req_url = URL(string: url_string)
        print(req_url!)
        let req = URLRequest(url: req_url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                let t = try decoder.decode([Timetable].self, from: data!)
                if t.count==0{
                    let _ = finished(false, t)
                }else{
                   let _ = finished(true, t)
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func return_station_janame(Station_name: String, finished: @escaping (Bool, String)->Void){
        var ja_name: String = ""
        let url_string = "https://api-tokyochallenge.odpt.org/api/v4/odpt:Station?owl:sameAs=" + Station_name + "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004"
        let req_url = URL(string: url_string)
        print(req_url!)
        let req = URLRequest(url: req_url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)  in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                self.station = try decoder.decode([Station_Data].self, from: data!)
                if self.station.count>0,  let n = self.station[0].station_object.ja{
                    ja_name = n
                }else {
                    ja_name = "****"
                }
                let _ = finished(true, ja_name)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func return_number_icon(name: String!) -> String{
        switch name {
        case "東海道線":
            return "800px-JR_JT_line_symbol.svg.png"
        case "横須賀線":
            return "200px-JR_JO_line_symbol.svg.png"
        case "京浜東北線・根岸線":
            return "200px-JR_JK_line_symbol.svg.png"
        case "横浜線":
            return "200px-JR_JH_line_symbol.svg.png"
        case "南武線":
            return "200px-JR_JN_line_symbol.svg.png"
        case "山手線":
            return "200px-JR_JY_line_symbol.svg.png"
        case "中央線快速":
            return "200px-JR_JC_line_symbol.svg.png"
        case "中央・総武各駅停車":
            return "200px-JR_JB_line_symbol.svg.png"
        case "総武快速線":
            return "200px-JR_JO_line_symbol.svg.png"
        case "宇都宮線":
            return "200px-JR_JU_line_symbol.svg.png"
        case "高崎線":
            return "200px-JR_JU_line_symbol.svg.png"
        case "埼京線・川越線":
            return "200px-JR_JA_line_symbol.svg.png"
        case "常磐線各駅停車":
            return "200px-JR_JL_line_symbol.svg.png"
        case "常磐線快速":
            return "200px-JR_JJ_line_symbol.svg.png"
        case "京葉線":
            return "200px-JR_JE_line_symbol.svg.png"
        case "武蔵野線":
            return "200px-JR_JM_line_symbol.svg.png"
        default:
            return "not find name"
        }
    }
    
    func return_traintype_janame(TrainType_name: String!, lang_flag: Int)->String{
        switch TrainType_name {
        case "odpt.TrainType:JR-East.ChuoSpecialRapid":
            if lang_flag == 1{return "中央特快"}
            else {return "Chuo Special Rapid"}
        case "odpt.TrainType:JR-East.CommuterRapid":
            if lang_flag == 1{return "通勤快速"}
            else {return "Commuter Rapid"}
        case "odpt.TrainType:JR-East.CommuterSpecialRapid":
            if lang_flag == 1{return "通勤特快"}
            else {return "Commuter Special Rapid"}
        case "odpt.TrainType:JR-East.Express":
            if lang_flag == 1{return "急行"}
            else {return "Express"}
        case "odpt.TrainType:JR-East.LimitedExpress":
            if lang_flag == 1{return "特急"}
            else {return "Limited Express"}
        case "odpt.TrainType:JR-East.Liner":
            if lang_flag == 1{return "ライナー"}
            else {return "Liner"}
        case "odpt.TrainType:JR-East.Local":
            if lang_flag == 1{return "普通"}
            else {return "Local"}
        case "odpt.TrainType:JR-East.OmeSpecialRapid":
            if lang_flag == 1{return "青梅特快"}
            else {return "Ome Special Rapid"}
        case "odpt.TrainType:JR-East.Rapid":
            if lang_flag == 1{return "快速"}
            else {return "Rapid"}
        case "odpt.TrainType:JR-East.SpecialRapid":
            if lang_flag == 1{return "特別快速"}
            else {return "Special Rapid"}
        default:
            return "cannot find this traintype"
        }
    }
    
    
    func resizeUIImageByWidth(image: UIImage, width: Double) -> UIImage {
        // オリジナル画像のサイズから、アスペクト比を計算
        let aspectRate = image.size.height / image.size.width
        // リサイズ後のWidthをアスペクト比を元に、リサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectRate))
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    //目的の降車駅を選択できるように修正
    @IBAction func destination_setting(_ sender: Any) {
        performSegue(withIdentifier: "goset_destination", sender: nil)
    }
    @IBOutlet weak var destination_name: UIButton!
    
    @IBAction func best_fordest(_ sender: Any) {
        
    }
    
    
}
