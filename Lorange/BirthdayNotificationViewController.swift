import UIKit

class BirthdayNotificationViewController: UIViewController {
    
    var birthdayName: String?
    var birthdayPicture: String?
    var birthdayPhone: String?
    
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var nameBox: UILabel!
    @IBOutlet weak var pictureBackground: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureBackground.layer.cornerRadius = pictureBackground.frame.size.width/2
        
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
    
    
    
    // using whatsapp
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        let whatsappURL: URL? = URL(string: "whatsapp://send?text=Happy+birthday%21")
        
        if UIApplication.shared.canOpenURL(whatsappURL!)
        {
            UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
        }

    }
    
}
