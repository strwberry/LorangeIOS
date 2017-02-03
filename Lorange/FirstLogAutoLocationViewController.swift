import UIKit

class FirstLogAutoLocationViewController: UIViewController {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    let network = UserDefaults.standard.string(forKey: "network")
    var semaphoreForVerdict: DispatchSemaphore?

    @IBOutlet weak var autoLocateSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    
    
    // edits autolocate and active in the database
    
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
    
    
    
    // running when segue validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToApp"
        {
            UserDefaults.standard.set(autoLocateSwitch.isOn, forKey: "autoLocation")
            
            var autoLocate = 0
            
            if autoLocateSwitch.isOn
            {
                autoLocate = 1
            }
            
            _ = editAutoLocate(network: network!, userID: userID, autoLocate: autoLocate)
        }
    }
}
