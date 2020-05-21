//
//  TrainTableViewCell.swift
//  searchTrain_Trial
///Users/kazu/Applications/searchTrain_Trial/searchTrain_Trial/Base.lproj/Main.storyboard
//  Created by 山本　一貴 on 2019/04/05.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit

class TrainTableViewCell: UITableViewCell {

    @IBOutlet weak var traintype_name: UILabel!
    @IBOutlet weak var direction_name: UILabel!
    @IBOutlet weak var departure_time: UILabel!
    @IBOutlet weak var delay: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
