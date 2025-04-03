//
//  LoginViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/2/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func loginClicked(_ sender: UIButton) {
        // Validate email and password fields
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        // Prepare URL and request
        guard let url = URL(string: "http://localhost:8080/api/users/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create payload to send to backend
        let loginPayload: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // Convert payload to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginPayload, options: [])
        } catch {
            showAlert(message: "Failed to encode login data.")
            return
        }

        // Send login request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(message: "Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(message: "Invalid response.")
                    return
                }

                if httpResponse.statusCode == 200 {
                    // Save login state (you could also decode a userId from `data` if you return it)
                    UserDefaults.standard.set(true, forKey: "isLoggedIn") // Flag that user is logged in
                    UserDefaults.standard.set(email, forKey: "loggedInEmail") // Save user email (or ID if you prefer)
                    
                    // ✅ Optional: Force UserDefaults to save immediately
                    UserDefaults.standard.synchronize()
                    
                    // Show sucess alert and Seque forward
                    let alert = UIAlertController(title: "✅ Success", message: "Logged in successfully!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                        self.performSegue(withIdentifier: "goToNext", sender: self)
                    })
                    self.present(alert, animated: true)
                } else {
                    self.showAlert(message: "❌ Invalid credentials. Please try again.")
                }
            }
        }.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


}
