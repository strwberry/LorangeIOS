import UIKit

class BirthdayNotificationViewController: UIViewController {
    
    var birthdayName: String?
    var birthdayPicture: String?
    var birthdayPhone: String?
    
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var nameBox: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureBox.layer.cornerRadius = pictureBox.frame.size.width/2
        
        pictureBox.clipsToBounds = true
        
        nameBox.text = birthdayName
        
        let url = URL(string: birthdayPicture!)
        
        let session = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let data = data
            {
                let image = UIImage(data: data)
                
                self.pictureBox.image = image
            }
        })
        
        session.resume()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        // send a message to birthday person when user hits the button
    }
    
}
