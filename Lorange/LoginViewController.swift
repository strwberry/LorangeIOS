import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func LoginClicked(_ sender: UIButton) {
        
        if emailBox.text!.isEmpty {
            emailBox.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName:UIColor.red])
            
        } else if passwordBox.text!.isEmpty {
            passwordBox.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor.red])
            
        } else {
            
            var request = URLRequest(url: URL(string: "http://faroanalytics.com/loginCheck.php")!)
            request.httpMethod = "POST"
            
            let body = "email=\(emailBox.text!.lowercased())&password=\(passwordBox.text!)"
            request.httpBody = body.data(using: String.Encoding.utf8)
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                data, response, error in
                    
                guard error == nil && data != nil else
                {
                    print("error:", error)
                    return
                }
                    
                let httpStatus = response as? HTTPURLResponse
                    
                if httpStatus!.expectedContentLength != 0
                {
                    do
                    {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Any]
                        print(json.count)
                    }
                    catch
                    {
                        print("Error creating the database")
                    }
                }
                else
                {
                    print("No data got from the URL")
                }
            })
            task.resume()
        }
    }
}







