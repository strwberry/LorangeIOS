import UIKit

class EditInfoViewController: UIViewController {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    let network = UserDefaults.standard.string(forKey: "network")
    var semaphoreForVerdict: DispatchSemaphore?
    var classMate: Alumni?
    /*var email: String?
    var phone: String?
    var job: String?
    var residence: String?
    var password: String?*/
    
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var phoneBox: UITextField!
    @IBOutlet weak var jobBox: UITextField!
    @IBOutlet weak var residenceBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var confirmPasswordBox: UITextField!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        _ = loadProfile(network: network!, userID: userID)
        
        emailBox.text = classMate?.email
        phoneBox.text = classMate?.phone
        jobBox.text = classMate?.job
        residenceBox.text = classMate?.residence
        passwordBox.text = classMate?.password
        confirmPasswordBox.text = classMate?.password
    }
    
    
    
    // untoggles the keyboard when user touches elsewhere on the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        emailBox.endEditing(true)
        
        phoneBox.endEditing(true)
        
        jobBox.endEditing(true)
        
        residenceBox.endEditing(true)
        
        passwordBox.endEditing(true)
        
        confirmPasswordBox.endEditing(true)
     }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
    }
    
    
    
    // Sends a request to server to get details about the class mate
    
    func loadProfile(network: String, userID: Int) -> Bool {
        
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
                    
                    self.classMate = Alumni(
                        userID: self.userID,
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
    
    
    
    // sends a request to the db to update info and returns true if ok
    
    func updateDB(network: String, userID: Int, email: String, phone: String, job: String, residence: String, password: String) -> Bool {
        
        var verdict = false
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/edit_v1.php")!)
        
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&email=\(email)&phone=\(phone)&job=\(job)&residence=\(residence)&password=\(password)"
        
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
                    verdict = json["success"] as! Bool
                    
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
    
    
    
    // updates profile data when user clicks on save
    @IBAction func saveChanges(_ sender: UIButton) {
        
        if updateDB(network: self.network!, userID: self.userID, email: emailBox.text!, phone: phoneBox.text!, job: jobBox.text!, residence: residenceBox.text!, password: passwordBox.text!)
        {
            performSegue(withIdentifier: "segueToProfile", sender: self)
        }
    }
    
    
    
    // implemented when a segue is about to be triggered
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToProfile"
        {
            let destinationVC = segue.destination as! ProfileViewController
            
            destinationVC.profileID = self.userID
        }
    }
    
    
}
