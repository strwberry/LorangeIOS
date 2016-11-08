import UIKit

class LoginViewController: UIViewController {
    
    var userID: Int?
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    // checking if the login is valid or not
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "segueToLocatorMap" {
            
            if emailBox.text!.isEmpty
            {
                emailBox.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSForegroundColorAttributeName:UIColor.red])
                
                return false
            }
            else if passwordBox.text!.isEmpty
            {
                passwordBox.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSForegroundColorAttributeName:UIColor.red])
                
                return false
            }
            else
            {
                self.emailBox.resignFirstResponder()
                
                let validLogin = CheckLogin(email: "\(emailBox.text!.lowercased())", password: "\(passwordBox.text!)")
                
                if validLogin
                {
                    return true
                }
                else
                {
                    return false
                }
            }
            
        } else { return false}
        
    }
        
    
    
    // sending the request to server and collecting the userID if accepted
    
    func CheckLogin(email: String, password: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://faroanalytics.com/loginCheck.php")!)
        request.httpMethod = "POST"
        
        let body = "email=\(email)&password=\(password)"
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
                    
                    if json["success"] as! Bool! == true
                    {
                        self.userID = json["userID"] as! Int!
                    }
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
    
    
    
    
    // running when segue validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToLocatorMap"
        {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
            UserDefaults.standard.set(self.userID, forKey: "userID")
            
            UserDefaults.standard.synchronize()
        }
    }
}

