//
//  ViewController.swift
//  AIFlower
//
//  Created by Matias Martinelli on 27/08/2023.
//

import UIKit
import CoreML
import Vision
import SDWebImage



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var wikiText: UILabel!
    
    private var imagePicker = UIImagePickerController()
    
    private var wikiManager = WikiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        wikiManager.delegate = self
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        if imageView.image == nil {
            imageView.image = UIImage(named: "takeapic")
        }
        
        wikiText.textColor = .white
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        guard let ciImage = CIImage(image: userPickedImage) else {
            fatalError("Could not conver to CIImage")
        }
        
        detect(image: ciImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: .init()).model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results?.first as? VNClassificationObservation else {
                fatalError("Model failed to proces image")
            }
            
            let flowerName = results.identifier.capitalized
            
            self.navigationItem.title = flowerName
            
            self.wikiManager.fetchWiki(flower: flowerName)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error with the handler \(error)")
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
}

extension ViewController: WikiManagerDelegate {
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
    func didUpdateWiki(_ wikiManager: WikiManager, wiki: WikiModel) {
        DispatchQueue.main.async {
            self.wikiText.text = wiki.extract
            self.imageView.sd_setImage(with: URL(string: wiki.flowerURl))
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}
