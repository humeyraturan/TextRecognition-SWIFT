//
//  ViewController.swift
//  TextRecognition
//
//  Created by Hümeyra Turan on 3.08.2023.
//
import Vision
import UIKit

class ViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Başlıyor..."
        return label
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "test")
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(imageView)
        
        recognizeText(image: imageView.image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20,
                                 y: view.safeAreaInsets.top,
                                 width: view.frame.size.width-40,
                                 height: view.frame.size.width-40)
        label.frame = CGRect(x: 20, y: view.frame.size.width + view.safeAreaInsets.top,
                             width: view.frame.size.width-40,
                             height: 200)
    }
    
    private func recognizeText(image: UIImage?) {
        guard let cgImage = image?.cgImage else {
            fatalError("could not get cgimage")
            
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // VNRecognizeTextRequest completion handler
        let completionHandler: (VNRequest, Error?) -> Void = { [weak self] request, error in
            // Check if there are results and if there is no error
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                // Handle error if present
                if let error = error {
                    DispatchQueue.main.async {
                        self?.label.text = "\(error)"
                    }
                }
                return
            }

            // Process recognized text
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")

            // Update the label with recognized text on the main thread
            DispatchQueue.main.async {
                self?.label.text = text
            }
        }

        // Create the VNRecognizeTextRequest with completion handler
        let request = VNRecognizeTextRequest(completionHandler: completionHandler)

        do {
            // Perform the request using a handler (handler should be declared earlier)
            try handler.perform([request])
        } catch {
            // Handle any errors that may occur during the request
            DispatchQueue.main.async {
                self.label.text = "\(error)"
            }
        }

        
    }
}
