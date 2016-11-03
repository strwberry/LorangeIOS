import Foundation
import UIKit

class LocatorMapViewController: UIViewController {
    
    @IBOutlet weak var Label: UILabel!
    var userID: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let userID = userID {
            Label.text = "\(userID)"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

