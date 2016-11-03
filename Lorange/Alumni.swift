import Foundation

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
    
    init (userID: Int, firstName: String, lastName: String, phone: String?, email: String, job: String?, birthDate: String, residence: String?, password: String, positionLat: Int, positionLng: Int, picture: String) {
        
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
}
