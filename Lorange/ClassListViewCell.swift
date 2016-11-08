import UIKit

class ClassListViewCell: UITableViewCell {
    
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var nameBox: UILabel!
    @IBOutlet weak var infoBox: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureBox.layer.cornerRadius = pictureBox.frame.size.width/2
        
        pictureBox.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
