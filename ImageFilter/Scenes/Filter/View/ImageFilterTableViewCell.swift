//
//  ImageFilterTableViewCell.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/7/20.
//

import UIKit

class ImageFilterTableViewCell: UITableViewCell {

    static let identifier = "ImageFilterTableViewCell"
    
    @IBOutlet weak var filterTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureLabel(typeName: String) {
        self.filterTypeLabel.text = typeName
    }

}
