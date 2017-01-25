import UIKit

class EditPictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let userID = UserDefaults.standard.integer(forKey: "userID")
    let network = UserDefaults.standard.string(forKey: "network")
    var semaphoreForPicture: DispatchSemaphore?
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    
    
    
    // when user clicks on the camera button
    @IBAction func takePicture(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = true
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            
            imagePicker.cameraCaptureMode = .photo
            
            imagePicker.modalPresentationStyle = .fullScreen
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    // when user clicks on the album button
    @IBAction func selectPicture(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = true
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            // imagePicker.modalPresentationStyle = .fullScreen
            
            imagePicker.modalPresentationStyle = .popover
            
            self.present(imagePicker, animated: true, completion: nil)
            
            // imagePicker.popoverPresentationController?.barButtonItem = backButton
            
        }
    }
    
    
    
    // gives directions to delegate if a picture is selected
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageName = createName()
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil
        {
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let selectedImage = crop(image: originalImage)
            
            let selectedImageData = UIImageJPEGRepresentation(selectedImage, 0.1)!
            
            let encodedString = selectedImageData.base64EncodedString(options: [])
            
            if updatePicture(network: self.network!, userID: userID, imageName: imageName, encodedString: encodedString)
            {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            // error: info can't be casted to an image
        }
        
    }
    
    
    
    // dismisses the camera if cancelled
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // loads new picture to the server and changes the picture reference in the db
    
    func updatePicture(network: String, userID: Int, imageName: String, encodedString: String) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://strwberry.io/db_files/picture_ios_v1.php")!)
        
        request.httpMethod = "POST"
        
        let body = "network=\(network)&userID=\(userID)&imageName=\(imageName)&encodedString=\(encodedString)"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil
            {
                print("error message: \(error)")
            }
            else
            {
                // success
            }
            self.semaphoreForPicture?.signal()
            
        }
        semaphoreForPicture = DispatchSemaphore.init(value: 0)
        
        task.resume()
        
        _ = semaphoreForPicture?.wait(timeout: DispatchTime.distantFuture)
        
        return true
    }
    
    
    
    // creates a unique name for new picture
    
    func createName() -> String {
        
        let calendar = Calendar(identifier: .gregorian)
        
        let dayStamp = calendar.component(.day, from: Date())
        
        let monthStamp = calendar.component(.month, from: Date())
        
        let yearStamp = calendar.component(.year, from: Date())
        
        let hourStamp = calendar.component(.hour, from: Date())
        
        let minuteStamp = calendar.component(.minute, from: Date())
        
        let secondStamp = calendar.component(.second, from: Date())
        
        return "\(userID)_\(yearStamp)_\(monthStamp)_\(dayStamp)_\(hourStamp)\(minuteStamp)\(secondStamp).jpg"
    }
    
    
    // crops an image
    
    func crop(image: UIImage) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var frame: CGRect
        
        if contextSize.height > contextSize.width
        {
            frame = CGRect(x: 0, y: (contextSize.height - contextSize.width)/2, width: contextSize.width, height: contextSize.width)
        }
        else
        {
            frame = CGRect(x: (contextSize.width - contextSize.height)/2, y: 0, width: contextSize.height, height: contextSize.height)
        }
        
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: frame)!
        
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    
    
    
}
