//
//  ImagesTableViewCell.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/2/20.
//

import UIKit

class ImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    
    static let identifier = "ImagesTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(using imageUrl: String) {
        NetworkManager.shared.downloadImage(with: imageUrl) { image in
            DispatchQueue.main.async {
                self.cellImageView.image = image
            }
        }
    }
}
