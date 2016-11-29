import UIKit
import UserNotifications

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    var email: String?
    var phone: String?
    var job: String?
    var residence: String?
    var password: String?
    var classList: [Alumni] = []
    var semaphoreForVerdict: DispatchSemaphore?
    var semaphoreForVerdict2: DispatchSemaphore?
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var phoneBox: UITextField!
    @IBOutlet weak var jobBox: UITextField!
    @IBOutlet weak var residenceBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var confirmPasswordBox: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        
        emailBox.text = email
        phoneBox.text = phone
        jobBox.text = job
        residenceBox.text = residence
        passwordBox.text = password
        confirmPasswordBox.text = password
        
    }
    
    
    
    // untoggles the keyboard when user touches elsewhere on the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        scrollView.endEditing(true)
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          UPDATE PICTURE                                    //
    ////////////////////////////////////////////////////////////////////////////////////////////////
    /*
    
    
    
    // when user clicks on the camera button
    
    @IBAction func takePicture(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = true
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    // 
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let date = Date()
        
        let calendar = Calendar.current
        
        let dayStamp = calendar.component(.year, from: date) + calendar.component(.month, from: date) + calendar.component(.day, from: date)
        
        let clockStamp = calendar.component(.hour, from: date) + calendar.component(.minute, from: date) + calendar.component(.second, from: date)
        
        let imageName = "\(userID)_\(dayStamp)\(clockStamp)"
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil
        {
            let encodedString = (info[UIImagePickerControllerOriginalImage] as? NSData)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            updatePicture(userID: userID, imageName: imageName, encodedString: encodedString!)
        }
        else
        {
            // error
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // loads new picture to the server and changes the picture reference in the db
    
    func updatePicture(userID: Int, imageName: String, encodedString: String) -> Bool {
        
        var verdict = false
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/picture.php")!)
        request.httpMethod = "POST"
        
        let body = "userID=\(userID)&imageName=\(imageName)&encodedString=\(encodedString)"
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
    
    
    
    */
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //                                  UPDATE PROFILE INFORMATION                                //
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    // sends a request to the db to update info and returns true if ok
    
    func updateDB(userID: Int, email: String, phone: String, job: String, residence: String, password: String) -> Bool {
        
        var verdict = false
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/edit.php")!)
        request.httpMethod = "POST"
        
        let body = "userID=\(userID)&email=\(email)&phone=\(phone)&job=\(job)&residence=\(residence)&password=\(password)"
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
        
        if updateDB(userID: self.userID, email: emailBox.text!, phone: phoneBox.text!, job: jobBox.text!, residence: residenceBox.text!, password: passwordBox.text!)
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
        else if segue.identifier == "segueToBirthdayNotification"
        {
            let destinationVC = segue.destination as! BirthdayNotificationViewController
            
            let birthdayClassMate = sender as! [String]
            
            destinationVC.birthdayName = birthdayClassMate[0] as String?
            
            destinationVC.birthdayPicture = birthdayClassMate[1] as String?
            
            destinationVC.birthdayPhone = birthdayClassMate[2] as String?
        }
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //                                  BIRTHDAY NOTIFICATIONS                                    //
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    // fills the classList array
    
    func loadClassList() -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwnerry.io/db_files/class.php")!)
        request.httpMethod = "POST"
        
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
            
            self.semaphoreForVerdict2?.signal()
        }
        
        semaphoreForVerdict2 = DispatchSemaphore.init(value: 0)
        
        task.resume()
        
        _ = semaphoreForVerdict2?.wait(timeout: DispatchTime.distantFuture)
        
        return true
    }
    
    
    
    // what happens when the notification switch gets touched
    
    @IBAction func notificationSwitched(_ sender: UISwitch) {
        
        if notificationSwitch.isOn
        {
            if loadClassList()
            {
                
                for i: Int in 0...classList.count - 1
                {
                    let requestIdentifier = "BD_\(classList[i].userID)"
                    
                    let content = UNMutableNotificationContent()
                    
                    content.title = "Birthday Notification"
                    
                    content.body = "It's \(classList[i].getName())'s birthday!"
                    
                    content.categoryIdentifier = "notificationCathegory"
                    
                    content.userInfo = ["classMateName": classList[i].getName(), "classMatePicture": classList[i].picture, "classMatePhone": classList[i].phone]
                    
                    content.sound = UNNotificationSound.default()
                    
                    // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: classList[i].getBirthday()), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil
                        {
                            print(error!)
                        }
                    })
                }
            }
        }
        else
        {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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

























