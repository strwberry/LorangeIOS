import UIKit
import MapKit
import CoreLocation

class LocatorMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // var userID: Int?
    let manager = CLLocationManager()
    
    @IBOutlet weak var Map: MKMapView!
    @IBOutlet weak var AddressBox: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Map.delegate = self
        
        locateUserAndStop()
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
            
            destinationVC.positionLat = Int(Map.centerCoordinate.latitude * 1000000)
            
            destinationVC.positionLng = Int(Map.centerCoordinate.longitude * 1000000)
        }
        else if segue.identifier == "logout"
        {
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            
            UserDefaults.standard.synchronize()
        }
    }

}

