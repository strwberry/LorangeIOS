import UIKit
import MapKit
import CoreLocation

class ClassMapViewController: UIViewController, MKMapViewDelegate {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    var positionLat: Int!
    var positionLng: Int!
    var classList = [Alumni]()
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var Map: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillLatLng()
        
        Map.delegate = self
        
        _ = loadClassList(userID: self.userID, positionLat: self.positionLat, positionLng: self.positionLng)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(46.510696, 6.619853), span: MKCoordinateSpanMake(120.0, 120.0))
        
        for i:Int in 0 ..< classList.count
        {
            addPin(classMate: classList[i])
        }
        
        Map.setRegion(region, animated: true)
    }
    
    
    
    // fills latitude and longitude if user doesnt come from locator
    
    func fillLatLng() {
        
        if positionLat == nil
        {
            positionLat = UserDefaults.standard.integer(forKey: "positionLat")
        }
        
        if positionLng == nil
        {
            positionLng = UserDefaults.standard.integer(forKey: "positionLng")
        }
    }
    
    
    
    // Sends a request to server to fill the classList
    
    func loadClassList(userID: Int, positionLat: Int, positionLng: Int) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://faroanalytics.com/markers.php")!)
        request.httpMethod = "POST"
        
        let body = "userID=\(userID)&positionLat=\(positionLat)&positionLng=\(positionLng)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
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
            
            self.semaphoreForVerdict?.signal()
            
        }
        
        semaphoreForVerdict = DispatchSemaphore.init(value: 0)
        
        task.resume()
        
        _ = semaphoreForVerdict?.wait(timeout: DispatchTime.distantFuture)
        
        return true
    }
    
    
    
    // adding pins on the map
    
    func addPin(classMate: Alumni) -> Void {
        
        let annotation: CustomMKPointAnnotation = CustomMKPointAnnotation()
        
        annotation.coordinate = classMate.getPosition()
        
        annotation.title = classMate.getName()
        
        annotation.userID = classMate.userID
        
        Map.addAnnotation(annotation)
    }
    
    
    
    // is called every time an annotation is about to be added to the map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        if annotationView == nil
        {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            annotationView?.canShowCallout = true
        }
        else
        {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "marker")
        
        let goToProfile = UIButton(type: .infoLight)
        
        annotationView?.rightCalloutAccessoryView = goToProfile
        
        return annotationView
    }
    
    
    
    // implementing a segue from the annotation callout
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let selctedClassMate = (view.annotation as! CustomMKPointAnnotation).userID
        
        performSegue(withIdentifier: "segueToOtherProfile", sender: selctedClassMate)
        
    }
    
    
    
    // running when segue validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueToMyProfile"
        {
            let destinationVC = segue.destination as! ProfileViewController
            
            destinationVC.profileID = self.userID
        }
        else if segue.identifier == "segueToOtherProfile"
        {
            let destinationVC = segue.destination as! ProfileViewController
            
            destinationVC.profileID = sender as! Int?
        }

    }
    
    
    
    // custom class
    
    class CustomMKPointAnnotation : MKPointAnnotation {
        var userID : Int?
    }
}
