//
//  ProductCell.swift
//  PurchaseDemo
//
//  Created by Sujan Vaidya on 12/18/17.
//  Copyright © 2017 Sujan Vaidya. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
