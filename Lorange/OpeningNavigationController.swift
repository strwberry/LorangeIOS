import UIKit

class OpeningNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isLoggedIn()
        {
            let contextStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if usesAutoLocation()
            {
                let classMapViewController: UIViewController = contextStoryBoard.instantiateViewController(withIdentifier: "ClassMap")
                
                viewControllers = [classMapViewController]
            }
            else
            {
                let locatorMapViewController: UIViewController = contextStoryBoard.instantiateViewController(withIdentifier: "LocatorMap")
                
                viewControllers = [locatorMapViewController]
            }
            
        }
        else
        {
            perform(#selector(showLoginViewController), with: nil, afterDelay: 0.01)
        }
        
    }
    
    
    
    // defines if the user is logged in
    
    fileprivate func isLoggedIn() -> Bool {
        
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    
    
    // defines if the user is using auto location
    
    fileprivate func usesAutoLocation() -> Bool {
        
        return UserDefaults.standard.bool(forKey: "autoLocation")
    }
    
    
    // displays the login view
    
    func showLoginViewController() {
        
        let contextStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController: UIViewController = contextStoryBoard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        
        present(loginViewController, animated: true, completion: {
            
            // here is where to put an animation
        })
        
    }
    
}


































