import UIKit

class FirstLogBirthdayViewController: UIViewController {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    let network = UserDefaults.standard.string(forKey: "network")
    var birthDate: String?
    var semaphoreForVerdict: DispatchSemaphore?

    
    @IBOutlet weak var birthdayBox: UIDatePicker!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        _ = getBirthday(network: network!, userID: userID)
        
        birthdayBox.setDate(getBirthdayDate(birthDate: birthDate!), animated: true)
    }
    
    
    
    // returns birthday from the database
    
    func getBirthday(network: String, userID: Int) -> Bool {
        
        
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
                    self.birthDate = (json["birthDate"]! as! String)
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
    
    
    
    // edits birthday in the database
    
    func editBirthday(network: String, userID: Int, birthDate: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/edit_birthday_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&birthDate=\(birthDate)"
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
    
    
    
    // returns a date from a string
    
    func getBirthdayDate(birthDate: String) -> Date {
        
        let calendarOfBirthDate = Calendar(identifier: .gregorian)
        
        var birthdayDateComponents = DateComponents()
        
        let dayRange = birthDate.index(birthDate.startIndex, offsetBy: 8)..<birthDate.index(birthDate.endIndex, offsetBy: 0)
        
        birthdayDateComponents.day = Int(birthDate.substring(with: dayRange))
        
        let monthRange = birthDate.index(birthDate.startIndex, offsetBy: 5)..<birthDate.index(birthDate.endIndex, offsetBy: -3)
        
        birthdayDateComponents.month = Int(birthDate.substring(with: monthRange))
        
        let yearRange = birthDate.index(birthDate.startIndex, offsetBy: 0)..<birthDate.index(birthDate.endIndex, offsetBy: -6)
        
        birthdayDateComponents.year = Int(birthDate.substring(with: yearRange))
        
        let dateComp = DateComponents(calendar: calendarOfBirthDate, timeZone: .current, year: birthdayDateComponents.year, month: birthdayDateComponents.month, day: birthdayDateComponents.day)
        
        return Calendar(identifier: .gregorian).date(from: dateComp)!
    }
    
    
    
    // returns a string from a date
    
    func getBirthdayString(birthdayDate: Date) -> String {
        
        let birthdayComponents = Calendar(identifier: .gregorian).dateComponents(in: .current, from: birthdayDate)
        
        return "\(birthdayComponents.year!)-\(birthdayComponents.month!)-\(birthdayComponents.day!)"
    }
    
    
    
    // running when segue validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToFirstLogCommunity"
        {
            _ = editBirthday(network: network!, userID: userID, birthDate: getBirthdayString(birthdayDate: birthdayBox.date))
        }
    }
}
