import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var manager = CLLocationManager()
    
    
    
    
    
    
    //////////////////////////////////////////////////////
    //      MANAGES THE START OF THE APP                //
    //////////////////////////////////////////////////////
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        //starts flurry
        
        Flurry.startSession("HNY74XG9JYVNV37KDSYH")
        
        
        
        // if app is launched by startMonitoringSignificantLocationChanges
        
        /*if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil
        {
            let newManager = CLLocationManager()
            
            newManager.delegate = self
            
            newManager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways
            {
                newManager.requestLocation()
            }
        }*/
        
        
        
        // if autolocation is on, get a location update
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            manager.delegate = self
            
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways
            {
                // manager.requestLocation()
            }
        }
        
        
        
        // manages which screen is shown after the logo
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.makeKeyAndVisible()
        
        window?.rootViewController = OpeningNavigationController()
        
        
        
        // requests permission for receiving notifications
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in if granted{}else{} })
        
        let activField = UNNotificationAction(identifier: "link", title: "click to see whos birthday it is", options: [.foreground])
        
        let notificationCathegory = UNNotificationCategory(identifier: "notificationCathegory", actions: [activField], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([notificationCathegory])
        
        
        
        return true
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////
    //                                                  //
    //////////////////////////////////////////////////////
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////
    //      MONITORS LOCATION CHANGES IN BACKGROUND     //
    //////////////////////////////////////////////////////
    
    // when the app enters the background
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            manager.delegate = self
            
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways
            {
                manager.allowsBackgroundLocationUpdates = true
                
                manager.startMonitoringSignificantLocationChanges()
            }
        }
    }
    
    
    
    // recieves new position after a significant position change is detected
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            let positionLat = Int(userLocation.coordinate.latitude * 1000000)
            
            let positionLng = Int(userLocation.coordinate.longitude * 1000000)
            
            let userID = UserDefaults.standard.integer(forKey: "userID")
                
            let network = UserDefaults.standard.string(forKey: "network")
            
            UserDefaults.standard.set(positionLat, forKey: "positionLat")
            
            UserDefaults.standard.set(positionLng, forKey: "positionLng")
            
            UserDefaults.standard.synchronize()
            
            updateLocation(network: network!, userID: userID, positionLat: positionLat, positionLng: positionLng)
        }
    }
    
    
    
    // prints the loction manager errors
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("LOCATIONMANAGERDELEGATE FAILED WITH ERROR: \(error)")
    }
    
    
    
    // sends new location to server
    
    func updateLocation(network: String, userID: Int, positionLat: Int, positionLng: Int) {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/locator_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&positionLat=\(positionLat)&positionLng=\(positionLng)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard error == nil, let data = data else{
            
                print("!!! REQUEST RETURNED ERROR: \(error) !!!")
                return
            }
            
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                
                if let json = json
                {
                    
                    if !(json["success"]! as! Bool)
                    {
                        print("!!! PHP ERROR: \(error) !!!")
                    }
                    else
                    {
                        print("location (\(positionLat), \(positionLng)) updated successfully")
                    }
                }
                
            }
            catch let error as NSError
            {
                print("!!! JSON ERROR: \(error) !!!")
            }
        }
        
        task.resume()
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////
    //      STOPS AUTO BACKGROUND LOCTION UPDATES       //
    //////////////////////////////////////////////////////
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        if UserDefaults.standard.bool(forKey: "autoLocation")
        {
            manager.stopMonitoringSignificantLocationChanges()
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways
            {
                // manager.requestLocation()
            }
        }
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////
    //                                                  //
    //////////////////////////////////////////////////////
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////
    //                                                  //
    //////////////////////////////////////////////////////
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}

