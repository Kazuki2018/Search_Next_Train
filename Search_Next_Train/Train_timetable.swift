//
//  Train_timetable.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/05/10.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit
import ISTimeline

class Train_timetable: UIViewController{
    var Traintimetable: Array<Dictionary<String, String>> = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let frame = CGRect(x: 175.0, y: 62.0, width: 200.0, height: 600.0)
        let timeline = ISTimeline(frame: frame)
        timeline.backgroundColor = .white
        timeline.bubbleColor = .init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        timeline.titleColor = .black
        timeline.descriptionColor = .darkText
        timeline.pointDiameter = 9.0
        timeline.lineWidth = 4.0
        timeline.bubbleRadius = 0.0
        loadcsvfile()
        display(table: self.Traintimetable[0], index: 0, timeline: timeline)
        
    }
    func display(table: Dictionary<String, String>, index: Int, timeline: ISTimeline){
        if index >= self.Traintimetable.count{
            return
        }
        var point: ISPoint
        if let time = table["odpt:departureTime"]{
            point = ISPoint(title: time + "発")
        }else{
            point = ISPoint(title: "到着")
        }
        var st_name : String = ""
        if let t = table["odpt:departureStation"]{
            st_name = t
        }else{
            if let s = table["odpt:arrivalStation"]{
                st_name = s
            }
        }
        let arr = st_name.components(separatedBy: ".")
        let en_name = arr[3]
        let ja_name = self.return_station_janame(en_name: en_name)
        point.description = ja_name
        point.lineColor = index % 2 == 0 ? .red : .green
        point.pointColor = point.lineColor
        timeline.points.append(point)
        
        if index+1 < self.Traintimetable.count {
            self.display(table: self.Traintimetable[index+1], index: index+1, timeline: timeline)
        }else{
            
            self.view.addSubview(timeline)
        }
        // Do any additional setup after loading the view.
    }
    
    public var Station: Array<String> = Array(repeating:"", count: 1518)
    
    func loadcsvfile(){
        do{
            if let csvPath = Bundle.main.path(forResource: "Stations_utf8_2", ofType: "csv")
            {
                let csvData = try String(contentsOfFile: csvPath, encoding:String.Encoding.utf8)
                //改行コードが\n一つになるようにします
                var lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
                lineChange = lineChange.replacingOccurrences(of: "\n\n", with: "\n")
                //"\n"の改行コードで区切って、配列csvArrayに格納する
                Station = lineChange.components(separatedBy: "\n")
            }
        } catch {
            print(error)
        }
    }
    
    func return_station_janame(en_name: String) -> String{
        for data in Station{
            let arr = data.components(separatedBy: ",")
            if(arr.count == 3){
                if (arr[2] == en_name) {
                    return arr[0]
                    
                }
            }
        }
        return "***"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func back_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
