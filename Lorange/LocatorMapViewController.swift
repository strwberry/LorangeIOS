import UIKit
import MapKit
import CoreLocation

class LocatorMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    let network = UserDefaults.standard.string(forKey: "network")
    let manager = CLLocationManager()
    var positionLat: Int?
    var positionLng: Int?
    let ZOOM = 0.05
    
    @IBOutlet weak var Map: MKMapView!
    @IBOutlet weak var AddressBox: UITextField!
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var aimGraphicElement: UIImageView!
    @IBOutlet weak var buttonGraphicElement: UIButton!
    @IBOutlet weak var searchGraphicElement: UIView!
    @IBOutlet weak var centerGraphicElement: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBox.layer.cornerRadius = viewBox.frame.size.height/2
        
        viewBox.clipsToBounds = true
        
        Map.delegate = self
        
        locateUser()
        
        // sets the screen to auto location being initialized
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            buttonGraphicElement.isHidden = true
            
            searchGraphicElement.isHidden = true
            
            centerGraphicElement.isHidden = true
            
            aimGraphicElement.isHidden = true
            
            logoutButton.isHidden = true
            
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            
            activityIndicator.center = self.view.center
            
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            let textView = UITextView(frame: CGRect(x: 0.0, y: self.view.frame.height - 50.0, width: self.view.frame.width, height: 50.0))
            
            textView.text = "Initializing auto-location..."
            
            textView.textAlignment = NSTextAlignment.center
            
            textView.backgroundColor = UIColor.white
            
            textView.textColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
            
            textView.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightThin)
            
            view.addSubview(textView)
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3)
            {
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.performSegue(withIdentifier: "segueToClassMap", sender: self)
            }

        }
        
    }
    
    
    
    // locates user when location button is touched
    
    @IBAction func locateUser(_ sender: UIButton) {
        
        locateUser()
    }
    
    
    
    // searches the location mentionned in the textfield
    
    @IBAction func searchLocation(_ sender: Any) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(AddressBox.text!, completionHandler: { (placemarks, error) -> Void in
            
            guard error == nil, placemarks == nil else
            {
                let location = placemarks?.first?.location
                
                let region = MKCoordinateRegion(center: (location!.coordinate), span: MKCoordinateSpanMake(self.ZOOM, self.ZOOM))
                
                self.Map.setRegion(region, animated: true)
                
                return
            }
        })
        
    }
    
    
    
    // display location on map movement
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: Map.centerCoordinate.latitude, longitude: Map.centerCoordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            
            guard error == nil else
            {
                print("!!! GEOCODER ERROR: \((error?.localizedDescription)!) !!!")
                return
            }
            
            if (placemarks?.count)! > 0
            {
                self.AddressBox!.text = placemarks?[0].locality
            }
            else
            {
                self.AddressBox!.text = "gone fishing"
            }
        })
        
        positionLat = Int(Map.centerCoordinate.latitude * 1000000)
        
        positionLng = Int(Map.centerCoordinate.longitude * 1000000)
        
    }
    
    
    
    // runs the location manager for 3 secs
    
    func locateUser() -> Void {
        
        manager.delegate = self
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            manager.requestAlwaysAuthorization()
            
            manager.startUpdatingLocation()
            
            manager.allowsBackgroundLocationUpdates = true
        }
        else
        {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            
            manager.requestWhenInUseAuthorization()
            
            manager.startUpdatingLocation()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3)
            {
                self.manager.stopUpdatingLocation()
            }
        }
        
    }
    
    
    
    // if autolocation is on, monitors location changes
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            manager.startMonitoringSignificantLocationChanges()
        }
        
    }
    
    
    
    // location manager locates user and moves the screen to his position
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        
        let position = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: position, span: MKCoordinateSpanMake(self.ZOOM, self.ZOOM))
        
        Map.setRegion(region, animated: true)
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            let positionLat = Int(userLocation.coordinate.latitude * 1000000)
            
            let positionLng = Int(userLocation.coordinate.longitude * 1000000)
            
            UserDefaults.standard.set(positionLat, forKey: "positionLat")
            
            UserDefaults.standard.set(positionLng, forKey: "positionLng")
            
            updateLocation(network: network!, userID: userID, positionLat: positionLat, positionLng: positionLng)
        }
        
    }
    
    
    
    // sends new location to server
    
    func updateLocation(network: String, userID: Int, positionLat: Int, positionLng: Int) {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/locator_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&positionLat=\(positionLat)&positionLng=\(positionLng)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard error == nil, let _ = data else{
                print("!!! URL_SESSION RETURNED AN ERROR OR NIL DATA !!!")
                return
            }
            
        }
        
        task.resume()
    }

    
    
    // untoggles the keyboard when user touches outside the textfield
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
        
    
    // running when a segue is validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToClassMap"
        {
            let destinationVC = segue.destination as! ClassMapViewController
            
            destinationVC.positionLat = self.positionLat
            
            destinationVC.positionLng = self.positionLng
            
            UserDefaults.standard.set(positionLat, forKey: "positionLat")
            
            UserDefaults.standard.set(positionLng, forKey: "positionLng")
        }
        else if segue.identifier == "logout"
        {
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            
            UserDefaults.standard.synchronize()
        }
    }

}



