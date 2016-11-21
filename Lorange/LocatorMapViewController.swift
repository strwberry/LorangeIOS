import UIKit
import MapKit
import CoreLocation

class LocatorMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    var positionLat: Int?
    var positionLng: Int?
    
    @IBOutlet weak var Map: MKMapView!
    @IBOutlet weak var AddressBox: UITextField!
    @IBOutlet weak var viewBox: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBox.layer.cornerRadius = viewBox.frame.size.height/2
        
        viewBox.clipsToBounds = true
        
        self.Map.delegate = self
        
        locateUserAndStop()
    }
    
    
    
    // locates user when location button is touched
    
    @IBAction func locateUser(_ sender: UIButton) {
        
        locateUserAndStop()
    }
    
    
    
    // searches the location mentionned in the textfield
    
    @IBAction func searchLocation(_ sender: Any) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(AddressBox.text!, completionHandler: { (placemarks, error) -> Void in
            
            guard error == nil, placemarks == nil else
            {
                let location = placemarks?.first?.location
                
                let region = MKCoordinateRegion(center: (location!.coordinate), span: MKCoordinateSpanMake(0.01, 0.01))
                
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
    
    func locateUserAndStop() -> Void {
        manager.delegate = self
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.requestWhenInUseAuthorization()
        
        manager.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3)
        {
            self.manager.stopUpdatingLocation()
        }
    }
    
    
    
    // location manager locates user and moves the screen to his position
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        
        let position = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: position, span: MKCoordinateSpanMake(0.01, 0.01))
        
        Map.setRegion(region, animated: true)
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



