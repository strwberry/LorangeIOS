import UIKit

class FirstLogNameViewController: UIViewController {
    
    var userID = UserDefaults.standard.integer(forKey: "userID")
    var network = UserDefaults.standard.string(forKey: "network")
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var semaphoreForVerdict: DispatchSemaphore?
  
    @IBOutlet weak var firstNameBox: UITextField!
    @IBOutlet weak var lastNameBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        _ = getName(network: network!, userID: userID)
        
        firstNameBox.text = firstName
        
        lastNameBox.text = lastName
        
        emailBox.text = email
    }
    
    
    
    // untoggles the keyboard when user touches elsewhere on the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    
    // returns name from the database
    
    func getName(network: String, userID: Int) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/profile_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)"
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
                    
                    self.firstName = (json["firstName"]! as! String)
                    
                    self.lastName = (json["lastName"]! as! String)
                    
                    self.email = (json["email"]! as! String)
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
    
    
    
    // edits name in the database
    
    func editName(network: String, userID: Int, firstName: String, lastName: String, email: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/edit_name_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&firstName=\(firstName)&lastName=\(lastName)&email=\(email)"
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
                    
                    if !(json["success"]! as! Bool)
                    {
                        print("!!! PHP ERROR: \(error) !!!")
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
        
        if segue.identifier == "segueToFirstLogBirthday"
        {
            _ = editName(network: network!, userID: userID, firstName: firstNameBox.text!, lastName: lastNameBox.text!, email: emailBox.text!)
        }
    }
}
