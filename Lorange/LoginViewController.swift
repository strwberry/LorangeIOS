import UIKit

class LoginViewController: UIViewController {
    
    var userID: Int?
    var network: String?
    var active: Int?
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    
    // untoggles the keyboard when user touches elsewhere on the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    
    // when login button gets clicked
    
    @IBAction func loginClicked(_ sender: UIButton) {
        
        if emailBox.text!.isEmpty
        {
            emailBox.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSForegroundColorAttributeName:UIColor.red])
        }
        else if passwordBox.text!.isEmpty
        {
            passwordBox.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSForegroundColorAttributeName:UIColor.red])
        }
        else
        {
            self.emailBox.resignFirstResponder()
            
            let validLogin = CheckLogin(email: "\(emailBox.text!.lowercased())", password: "\(passwordBox.text!)")
            
            if validLogin
            {
                if active! > 1
                {
                    performSegue(withIdentifier: "segueToLocatorMap", sender: self)
                }
                else
                {
                    performSegue(withIdentifier: "segueToFirstLog", sender: self)
                }
            }
            else
            {
                let alert = UIAlertController(title: "Login failed", message: "The email or password you used was incorrect", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    // sending the request to server and collecting the userID if accepted
    
    func CheckLogin(email: String, password: String) -> Bool {
        
        var verdict = false
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/login_v1.php")!)
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
                        
                        self.network = json["network"] as! String!
                        
                        self.active = json["active"] as! Int!
                        
                        verdict = true
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
        
        return verdict
    }
    
    
    
    
    // running when segue validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToLocatorMap" || segue.identifier == "segueToFirstLog"
        {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
            UserDefaults.standard.set(self.userID, forKey: "userID")
            
            UserDefaults.standard.set(self.network, forKey: "network")
            
            UserDefaults.standard.synchronize()
        }
    }
}

