import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!

    @IBOutlet weak var bmiTextField: UITextField!
    @IBOutlet weak var riskTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    var firstLink: String?

    @IBAction func callBMIAPIButtonPressed(_ sender: UIButton) {
        struct BMIResponse: Codable {
            let bmi: Double
            let more: [String]
        }

        guard let heightText = heightTextField.text,
              let weightText = weightTextField.text,
              let height = Double(heightText),
              let weight = Double(weightText) else {
            // handle invalid input
            return
        }

        // Make an API call to the calculateBMI endpoint with height and weight parameters
        let urlString = "http://webstrar99.fulton.asu.edu/page8/Service1.svc/calculateBMI?height=\(height)&weight=\(weight)"
        guard let url = URL(string: urlString) else {
            // handle invalid URL
            return
        }

        // Handle the API response and parse the JSON data
        let urlSession = URLSession.shared

        let jsonQuery = urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Handle error here
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                // Handle missing data here
                return
            }

            do {
                let decoder = JSONDecoder()
                let jsonResult = try decoder.decode(BMIResponse.self, from: data)
                let bmi = jsonResult.bmi
                self.firstLink = jsonResult.more.first

                // Update the UI with the calculated BMI, risk factor, and display the web links
                DispatchQueue.main.async {
                    self.bmiTextField.text = String(format: "%.2f", bmi)
                    if bmi < 18 {
                        self.riskTextField.text = "Blue"
                        self.messageTextField.text = "You are underweight"
                        self.riskTextField.textColor = UIColor.blue
                        self.messageTextField.textColor = UIColor.blue
                        self.bmiTextField.textColor = UIColor.blue
                    } else if bmi < 25 {
                        self.riskTextField.text = "Green"
                        self.messageTextField.text = "You are normal"
                        self.riskTextField.textColor = UIColor.green
                        self.messageTextField.textColor = UIColor.green
                        self.bmiTextField.textColor = UIColor.green
                    } else if bmi < 30 {
                        self.riskTextField.text = "Purple"
                        self.messageTextField.text = "You are pre-obese"
                        self.riskTextField.textColor = UIColor.purple
                        self.messageTextField.textColor = UIColor.purple
                        self.bmiTextField.textColor = UIColor.purple
                    } else {
                        self.riskTextField.text = "Red"
                        self.messageTextField.text = "You are obese :("
                        self.riskTextField.textColor = UIColor.red
                        self.messageTextField.textColor = UIColor.red
                        self.bmiTextField.textColor = UIColor.red
                    }
                }
            } catch {
                // Handle JSON parsing error here
                print("JSON Parsing Error: \(error)")
            }
        }
        jsonQuery.resume()
    }
    
    
    @IBAction func educateMeButtonPressed(_ sender: UIButton) {
        guard let firstLink = self.firstLink, let url = URL(string: firstLink) else {
                    // Handle the case where there are no links or the first link is invalid
                    return
                }
                
                // Open the first link in the default web browser
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

