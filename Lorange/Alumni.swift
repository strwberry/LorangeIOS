// import Foundation
import MapKit

class Alumni {
    var userID: Int
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var job: String
    var birthDate: String
    var residence: String
    var password: String
    var positionLat: Int
    var positionLng: Int
    var picture: String
    
    
    
    // constructor
    
    init(userID: Int, firstName: String, lastName: String, phone: String?, email: String, job: String?, birthDate: String, residence: String?, password: String, positionLat: Int, positionLng: Int, picture: String) {
        
        self.userID = userID
        
        self.firstName = firstName
        
        self.lastName = lastName
        
        if let phone = phone {
            self.phone = phone
        } else {self.phone = "???"}
        
        self.email = email
        
        if let job = job{
            self.job = job
        }else {self.job = "???"}
        
        self.birthDate = birthDate
        
        if let residence = residence {
            self.residence = residence
        }else {self.residence = "???"}
        
        self.password = password
        
        self.positionLat = positionLat
        
        self.positionLng = positionLng
        
        self.picture = picture
    }
    
    
    
    // returns the map location of the alumni
    
    func getPosition () -> CLLocationCoordinate2D {
        
        return CLLocationCoordinate2DMake(Double(self.positionLat)/1000000, Double(self.positionLng)/1000000)
    }
    
    
    
    // returns the complete name of an alumni
    
    func getName () -> String {
        
        return self.firstName + " " + self.lastName
    }
    
    
    
    // returns the birthday as a date
    
    func getBirthday() -> Date {
        
        let dateFormatter = DateFormatter()
        
        DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: nil)
        
        var date = Date(timeIntervalSinceNow: 5)
        
        date = dateFormatter.date(from: self.birthDate)!
        
        return date
    }

}



















