//
//  CollectionCell.swift
//  PhotosProvider
//
//  Created by Hiroshi Kimura on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import UIKit

class CollectionCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
}
