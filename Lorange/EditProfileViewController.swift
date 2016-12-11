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
    var semaphoreForPicture: DispatchSemaphore?
    
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
        
        if UserDefaults.standard.bool(forKey: "notifications")
        {
           notificationSwitch.isOn = true
        }
        else
        {
            notificationSwitch.isOn = false
        }
        
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
    
    
    
    
    // when user clicks on the camera button
    
    @IBAction func takePicture(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = true
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            
            imagePicker.cameraCaptureMode = .photo
            
            imagePicker.modalPresentationStyle = .fullScreen
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    // gives directions to delegate if a picture is selected
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageName = createName()
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil
        {
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let selectedImage = crop(image: originalImage)
            
            let selectedImageData = UIImageJPEGRepresentation(selectedImage, 0.1)!
            
            let encodedString = selectedImageData.base64EncodedString(options: [])
            
            if updatePicture(userID: userID, imageName: imageName, encodedString: encodedString)
            {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            // error: info can't be casted to an image
        }
        
    }
    
    
    
    // dismisses the camera if cancelled
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // loads new picture to the server and changes the picture reference in the db
    
    func updatePicture(userID: Int, imageName: String, encodedString: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/picture_ios.php")!)
        
        request.httpMethod = "POST"
        
        let body = "userID=\(userID)&imageName=\(imageName)&encodedString=\(encodedString)"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil
            {
                print("error message: \(error)")
            }
            else
            {
                // success
            }
            self.semaphoreForPicture?.signal()
            
        }
        semaphoreForPicture = DispatchSemaphore.init(value: 0)
        
        task.resume()
        
        _ = semaphoreForPicture?.wait(timeout: DispatchTime.distantFuture)
        
        return true
    }
    
    
    
    // creates a unique name for new picture
    
    func createName() -> String {
        
        let calendar = Calendar(identifier: .gregorian)
        
        let dayStamp = calendar.component(.day, from: Date())
        
        let monthStamp = calendar.component(.month, from: Date())
        
        let yearStamp = calendar.component(.year, from: Date())
        
        let hourStamp = calendar.component(.hour, from: Date())
        
        let minuteStamp = calendar.component(.minute, from: Date())
        
        let secondStamp = calendar.component(.second, from: Date())
        
        return "\(userID)_\(yearStamp)_\(monthStamp)_\(dayStamp)_\(hourStamp)\(minuteStamp)\(secondStamp).jpg"
    }
    
    
    // crops an image
    
    func crop(image: UIImage) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var frame: CGRect
        
        if contextSize.height > contextSize.width
        {
            frame = CGRect(x: 0, y: (contextSize.height - contextSize.width)/2, width: contextSize.width, height: contextSize.width)
        }
        else
        {
            frame = CGRect(x: (contextSize.width - contextSize.height)/2, y: 0, width: contextSize.height, height: contextSize.height)
        }
        
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: frame)!
        
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    
    
    
    
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
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/class.php")!)
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
            }
        }
        else
        {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            UserDefaults.standard.set(false, forKey: "notifications")
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
        
        birthdayDateComponents.hour = 12
        
        birthdayDateComponents.minute = 26
        
        birthdayDateComponents.second = 0
        
        return DateComponents(calendar: calendarOfNextBirthday, timeZone: .current, month: birthdayDateComponents.month, day: birthdayDateComponents.day, hour: birthdayDateComponents.hour, minute: birthdayDateComponents.minute)
        
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


