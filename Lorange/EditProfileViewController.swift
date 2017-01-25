import UIKit

class EditProfileViewController: UIViewController {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    var email: String?
    var phone: String?
    var job: String?
    var residence: String?
    var password: String?
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    
    // implemented when a segue is about to be triggered
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sequeToProfile" {
            
            let destinationVC = segue.destination as! ProfileViewController
            
            destinationVC.profileID = self.userID
        }
        
    }
}

