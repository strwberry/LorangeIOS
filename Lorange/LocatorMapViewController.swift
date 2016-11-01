import Foundation
import UIKit

class LocatorMapViewController: UIViewController {
    
    @IBOutlet weak var Label: UILabel!
    
    var labelText = String()
    
    override func viewDidLoad() {
        Label.text = labelText
    }
}

