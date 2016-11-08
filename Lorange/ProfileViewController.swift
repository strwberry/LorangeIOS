import UIKit

class ProfileViewController: UIViewController {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    var profileID: Int?
    var classMate: Alumni?
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var pictureBox: UIImageView!
    @IBOutlet weak var birthdayBox: UILabel!
    @IBOutlet weak var emailBox: UILabel!
    @IBOutlet weak var phoneBox: UILabel!
    @IBOutlet weak var residenceBox: UILabel!
    @IBOutlet weak var workBox: UILabel!
    
    
    
     
     // sending whatsapp to a contact
    
    @IBAction func sendWhatsapp(_ sender: UIButton) {
        
        // apple doesn't allow to use whatsapp. find something else
        
    }
    
 
    
    
    override func viewDidLoad() {
        
        pictureBox.layer.cornerRadius = pictureBox.frame.size.width/2
        
        pictureBox.clipsToBounds = true
        
        _ = loadProfile(userID: profileID!)
        
        fillBoxes()
        
    }
    
    
    
    // Sends a request to server to fill the classList
    
    func loadProfile(userID: Int) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://faroanalytics.com/profiles.php")!)
        request.httpMethod = "POST"
        
        let body = "userID=\(userID)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard error == nil, let data = data else{
                print("!!! URL_SESSION RETURNED AN ERROR OR NIL DATA !!!")
                return
            }
            
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                
                if let json = json
                {
                    
                    self.classMate = Alumni(
                        userID: self.profileID!,
                        firstName: json["firstName"]! as! String,
                        lastName: json["lastName"]! as! String,
                        phone: json["phone"]! as? String,
                        email: json["email"]! as! String,
                        job: json["job"]! as? String,
                        birthDate: json["birthDate"]! as! String,
                        residence: json["residence"]! as? String,
                        password: json["password"]! as! String,
                        positionLat: json["positionLat"]! as! Int,
                        positionLng: json["positionLng"]! as! Int,
                        picture: json["picture"]! as! String)
                    
                }
                
            }
            catch let error as NSError
            {
                print("!!! JSON ERROR: \(error) !!!")
            }
            
            self.semaphoreForVerdict?.signal()
            
        }
        
        semaphoreForVerdict = DispatchSemaphore.init(value: 0)
        
        task.resume()
        
        _ = semaphoreForVerdict?.wait(timeout: DispatchTime.distantFuture)
        
        return true
    }
    
    
    
    // fills the boxes with alumni profile info
    
    func fillBoxes() {
        
        birthdayBox.text = classMate?.birthDate
        
        emailBox.text = classMate?.email
        
        phoneBox.text = classMate?.phone
        
        residenceBox.text = classMate?.residence
        
        workBox.text = classMate?.job
        
        let url = URL(string: (classMate?.picture)!)!
        
        let session = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let data = data
            {
                let image = UIImage(data: data)
                
                self.pictureBox.image = image
            }
        })
        
        session.resume()
        
    }

    
}
