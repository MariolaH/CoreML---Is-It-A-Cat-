//
//  ViewController.swift
//  SeeFood
//
//  Created by Mariola Hullings on 9/12/23.
//

import UIKit
import CoreML //Used for integrating machine learning models into app
import Vision //Apple’s framework for working with computer vision algorithms.

//ViewController class inherits from UIViewController and adopts two delegate protocols
//UIImagePickerControllerDelegate: Helps in managing user interactions with an image picker interface
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //UIImage in the storyboard
    @IBOutlet var ImageView: UIImageView!
    //imagePicker: An instance of UIImagePickerController used to let the user pick images.
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self ie. this VC
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    //gets triggered when an image is selected using the UIImagePickerController ie. when the user takes a photo or selects one from their gallery
    //func accepts two parameters:
    //picker: The instance of UIImagePickerController that is responsible for the event
    //info: A dictionary containing various details about the media (in this case, the image) that was selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Try to access the original, unedited image from the info dictionary using the key UIImagePickerController.InfoKey.originalImage
        //Attempt to type-cast the retrieved value as a UIImage
        //If successful, the retrieved image is stored in the userPickedImage constant.
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //Set the ImageView's image property to the userPickedImage, effectively displaying the selected image in the user interface
            ImageView.image = userPickedImage
            //converts the userPickedImage from a UIImage format to a CIImage format.
            //conversion is essential because the subsequent image processing, especially with Apple's Vision framework, often uses the CIImage format.
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            // method to run image classification
            //runs the image through a machine learning model to classify or detect its content
            detect(image: ciimage)
        }
        //After the image has been selected and processed, the UIImagePickerController (camera or photo library interface) is dismissed, and the user is returned to the original view.
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed To Process Image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("cat") {
                    self.navigationItem.title = "It's A Cat!"
                } else {
                    self.navigationItem.title = "It's Not A Cat!"
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

