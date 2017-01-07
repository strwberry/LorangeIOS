import UIKit

class ClassListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let network = UserDefaults.standard.string(forKey: "network")
    var classList = [Alumni]()
    var semaphoreForVerdict: DispatchSemaphore?
    var semaphoreForImage: DispatchSemaphore?
    var image: UIImage = UIImage()
    
    
    @IBOutlet weak var TableView: UITableView!
    
    
    
    // methods for the tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: "cell") as! ClassListViewCell
        
        cell.nameBox.text = classList[indexPath.row].getName()
        
        cell.infoBox.text = classList[indexPath.row].job + ", " + classList[indexPath.row].residence
        
        cell.pictureBox.image = loadPicture(rowNumber: indexPath.row)
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = loadClassList(network: self.network!)
        
        TableView.dataSource = self
        
        TableView.delegate = self
    }
    
    
    
    // Sends a request to server to fill the classList
    
    func loadClassList(network: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/class_v1.php")!)
        request.httpMethod = "POST"
        
        let body = "network=\(network)"
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
    
    
    
    //
    
    func loadPicture(rowNumber: Int) -> UIImage {
        
        let url = URL(string: classList[rowNumber].picture)
        
        let session = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let data = data
            {
                self.image = UIImage(data: data)!
            }
            self.semaphoreForImage?.signal()
            
        })
        
        semaphoreForImage = DispatchSemaphore.init(value: 0)
        
        session.resume()
        
        _ = semaphoreForImage?.wait(timeout: DispatchTime.distantFuture)
        
        return image
    }
    
    
    
    // running right before the segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToProfile"
        {
            
            if let indexPath = TableView.indexPathForSelectedRow
            {
                let destinationVC = segue.destination as! ProfileViewController
                
                destinationVC.profileID = classList[indexPath.row].userID
            }
            
        }
        
    }
    
    
}
