import UIKit

class EditPositionViewController: UIViewController {
    
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
    
    
    @IBAction func setAutoLocation(_ sender: Any) {
        
        if autoLocationSwitch.isOn
        {
            UserDefaults.standard.set(true, forKey: "autoLocation")
            
            performSegue(withIdentifier: "segueToUpdateLocation", sender: self)
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "autoLocation")
            
            performSegue(withIdentifier: "segueToUpdateLocation", sender: self)
        }

    }
    
    
}
