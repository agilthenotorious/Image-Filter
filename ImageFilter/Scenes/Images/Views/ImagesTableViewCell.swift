//
//  ImagesTableViewCell.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/2/20.
//

import UIKit

class ImagesTableViewCell: UITableViewCell {

    static let identifier = "ImagesTableViewCell"
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImageView.image = nil
    }
    
    func configureCell(using imageUrl: String, filter: ImageFilterType) {
        NetworkManager.shared.downloadFilterImage(with: imageUrl, filter: filter) { image in
            DispatchQueue.main.async {
                self.cellImageView.image = image
            }
        }
    }
}
