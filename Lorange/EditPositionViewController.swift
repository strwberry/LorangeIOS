import UIKit

class EditPositionViewController: UIViewController {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    let network = UserDefaults.standard.string(forKey: "network")
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var autoLocationSwitch: UISwitch!
    @IBOutlet weak var positionUpdateButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            autoLocationSwitch.isOn = true
            
            positionUpdateButton.isUserInteractionEnabled = false
        }
        else
        {
            autoLocationSwitch.isOn = false
            
            positionUpdateButton.isUserInteractionEnabled = true
        }
    }
    
    
    
    // what happens when the auto location switch is flipped
    
    @IBAction func setAutoLocation(_ sender: Any) {
        
        if autoLocationSwitch.isOn
        {
            UserDefaults.standard.set(true, forKey: "autoLocation")
            
            _ = editAutoLocate(network: network!, userID: userID, autoLocate: 1)
            
            performSegue(withIdentifier: "segueToUpdateLocation", sender: self)
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "autoLocation")
            
            _ = editAutoLocate(network: network!, userID: userID, autoLocate: 0)
            
            performSegue(withIdentifier: "segueToUpdateLocation", sender: self)
        }

    }
    
    
    
    // edits autolocate in the database
    
    func editAutoLocate(network: String, userID: Int, autoLocate: Int) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/auto_locate_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&autoLocate=\(autoLocate)"
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
    
    
}
