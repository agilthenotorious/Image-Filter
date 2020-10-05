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
    
    func configureCell(using image: ImageInfo?) {
        guard let imageInfo = image, let urlStr = imageInfo.url, let url = URL(string: urlStr) else { return }
        cellImageView.downloadImage(with: url)
    }

}

extension UIImageView {
    func downloadImage(with url: URL) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            } catch {
                print(error)
            }
        }
    }
}
