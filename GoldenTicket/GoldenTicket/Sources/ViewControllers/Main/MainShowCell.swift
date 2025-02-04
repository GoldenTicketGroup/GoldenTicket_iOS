//
//  MainShowCell.swift
//  GoldenTicket
//
//  Created by 안재은 on 30/06/2019.
//  Copyright © 2019 황수빈. All rights reserved.
//

import UIKit

class MainShowCell: UICollectionViewCell {
    
    var showIndex: Int!
    
    @IBOutlet weak var showImage: UIImageView!
    
    @IBOutlet weak var showTitle: UILabel!
    
    @IBOutlet weak var showLocation: UILabel!
    
    @IBOutlet weak var showTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showImage.layer.cornerRadius = 20
        showImage.layer.masksToBounds = true
    }

}
