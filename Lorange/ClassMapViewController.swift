import UIKit
import MapKit
import CoreLocation

class ClassMapViewController: UIViewController, MKMapViewDelegate {
    
    var userID: Int?
    var positionLat: Int?
    var positionLng: Int?
    var classList = [Alumni]()
    // var semaphoreForZoom: DispatchSemaphore?
    var semaphoreForVerdict: DispatchSemaphore?
    
    @IBOutlet weak var Map: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // _ = MKCoordinateRegion(center: CLLocationCoordinate2DMake(1, 2), span: MKCoordinateSpanMake(100, 100))
        
        // semaphoreForZoom = DispatchSemaphore.init(value: 0)
        
        Map.delegate = self
        
        _ = loadClassList(userID: self.userID!, positionLat: self.positionLat!, positionLng: self.positionLng!)
        
        // _ = semaphoreForZoom?.wait(timeout: DispatchTime.distantFuture)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(46.510696, 6.619853), span: MKCoordinateSpanMake(120.0, 120.0))
        
        Map.setRegion(region, animated: true)
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
                        
                        self.addPin(location: self.classList[i].getPosition(), name: self.classList[i].getName())
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
        
        // semaphoreForZoom?.signal()
        
        return true
    }
    
    
    
    // adding pins on the map
    
    func addPin(location: CLLocationCoordinate2D, name: String?) -> Void {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        
        annotation.title = name
        
        Map.addAnnotation(annotation)
        
    }
    
    
    
    // running when segue validated
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToClassList"
        {
            let destinationVC = segue.destination as! ClassListViewController
            
            destinationVC.userID = self.userID
        }
        else if segue.identifier == "segueToProfile"
        {
            let destinationVC = segue.destination as! ProfileViewController
            
            destinationVC.userID = self.userID
        }
    }

}
