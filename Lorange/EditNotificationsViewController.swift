import UIKit
import UserNotifications

class EditNotificationsViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    let network = UserDefaults.standard.string(forKey: "network")
    let userID = UserDefaults.standard.integer(forKey: "userID")
    var classList: [Alumni] = []
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var birthdayNotificationSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        
        if UserDefaults.standard.bool(forKey: "notifications")
        {
            birthdayNotificationSwitch.isOn = true
        }
        else
        {
            birthdayNotificationSwitch.isOn = false
        }
    }
    
    
    
    // fills the classList array
    
    func loadClassList(network: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/class_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard error == nil, let data = data else{
                print("!!! URL_SESSION RETURNED AN ERROR OR NIL DATA !!!")
                return
            }
            
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Dictionary<String, String>]
                
                if let json = json
                {
                    
                    for i:Int in 0 ..< json.count
                    {
                        
                        self.classList.append(Alumni(
                            userID: Int(json[i]["userID"]!)!,
                            firstName: json[i]["firstName"]!,
                            lastName: json[i]["lastName"]!,
                            phone: json[i]["phone"]!,
                            email: json[i]["email"]!,
                            job: json[i]["job"]!,
                            birthDate: json[i]["birthDate"]!,
                            residence: json[i]["residence"]!,
                            password: json[i]["password"]!,
                            positionLat: Int(json[i]["positionLat"]!)!,
                            positionLng: Int(json[i]["positionLng"]!)!,
                            picture: json[i]["picture"]!)
                        )
                        
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
    
    
    
    // what happens when the notification switch gets touched
    @IBAction func notificationSwitched(_ sender: UISwitch) {
        
        if birthdayNotificationSwitch.isOn
        {
            if loadClassList(network: self.network!)
            {
                
                for i: Int in 0...(classList.count - 1)
                {
                    let requestIdentifier = "BD_\(classList[i].userID)"
                    
                    let content = UNMutableNotificationContent()
                    
                    content.title = "Birthday Notification"
                    
                    content.body = "It's \(classList[i].getName())'s birthday!"
                    
                    content.categoryIdentifier = "notificationCathegory"
                    
                    content.userInfo = ["classMateName": classList[i].getName(), "classMatePicture": classList[i].picture, "classMatePhone": classList[i].phone]
                    
                    content.sound = UNNotificationSound.default()
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: getBirthday(alumni: classList[i]), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil
                        {
                            print(error!)
                        }
                    })
                }
                UserDefaults.standard.set(true, forKey: "notifications")
                
                _ = editNotification(network: network!, userID: userID, notification: 1)
            }
        }
        else
        {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            UserDefaults.standard.set(false, forKey: "notifications")
            
            _ = editNotification(network: network!, userID: userID, notification: 0)
        }
    }
    
    
    
    // returns the alumni's next birthday as a date
    
    func getBirthday(alumni: Alumni) -> DateComponents {
        
        let str = alumni.birthDate
        
        let calendarOfNextBirthday = Calendar(identifier: .gregorian)
        
        var birthdayDateComponents = DateComponents()
        
        let dayRange = str.index(str.startIndex, offsetBy: 8)..<str.index(str.endIndex, offsetBy: 0)
        
        birthdayDateComponents.day = Int(str.substring(with: dayRange))
        
        let monthRange = str.index(str.startIndex, offsetBy: 5)..<str.index(str.endIndex, offsetBy: -3)
        
        birthdayDateComponents.month = Int(str.substring(with: monthRange))
        
        birthdayDateComponents.hour = 8
        
        birthdayDateComponents.minute = 0
        
        birthdayDateComponents.second = 0
        
        return DateComponents(calendar: calendarOfNextBirthday, timeZone: .current, month: birthdayDateComponents.month, day: birthdayDateComponents.day, hour: birthdayDateComponents.hour, minute: birthdayDateComponents.minute)
        
    }
    
    
    
    // edits notification in the database
    
    func editNotification(network: String, userID: Int, notification: Int) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/notification_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&notification=\(notification)"
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
    
    
    
    // implemented when a segue is about to be triggered
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToBirthdayNotification"
        {
            let destinationVC = segue.destination as! BirthdayNotificationViewController
            
            let birthdayClassMate = sender as! [String]
            
            destinationVC.birthdayName = birthdayClassMate[0] as String?
            
            destinationVC.birthdayPicture = birthdayClassMate[1] as String?
            
            destinationVC.birthdayPhone = birthdayClassMate[2] as String?
        }
    }
}



// handles notifications when the app is on the forefront

extension EditProfileViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let senderName  = response.notification.request.content.userInfo["classMateName"] as! String
        
        let senderPicture  = response.notification.request.content.userInfo["classMatePicture"] as! String
        
        let senderPhone  = response.notification.request.content.userInfo["classMatePhone"] as! String
        
        let sender = [senderName, senderPicture, senderPhone]
        
        performSegue(withIdentifier: "segueToBirthdayNotification", sender: sender)
    }
    
    
}




