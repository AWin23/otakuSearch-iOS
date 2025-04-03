//
//  CreateAccountViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/2/25.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        // Auto-generate a username from the email prefix
        let username = email.components(separatedBy: "@").first ?? "user"

        // Prepare the user payload for registration
        let newUser: [String: Any] = [
            "userName": username,
            "email": email,
            "password": password
        ]
        
        // POST request into MySQL DB on Azure for Account Creation
        guard let url = URL(string: "http://localhost:8080/api/users/register") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert the Swift dictionary to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: newUser, options: [])
        } catch {
            showAlert(message: "Failed to encode user data.")
            return
        }
        
        // Execute the request
        // 🚀 1. Send the request asynchronously
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // ❌ 2. Handle network or request errors
                if let error = error {
                    self.showAlert(message: "Error: \(error.localizedDescription)")
                    return
                }

                // 🔎 3. Check the status code to confirm success or failure
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(message: "Invalid response.")
                    return
                }

                // ✅ 4. Show user feedback based on response code
                if httpResponse.statusCode == 200 {
                    // Show success alert, then segue
                    let alert = UIAlertController(title: "✅ Success", message: "Account created!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                        self.performSegue(withIdentifier: "goToNext", sender: self)
                    })
                    self.present(alert, animated: true)
                    
                    // stores the email into the user session
                    UserDefaults.standard.set(email, forKey: "loggedInEmail")

                } else {
                    self.showAlert(message: "Failed to create account. Code: \(httpResponse.statusCode)")
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
    
    // helper function to display alert message
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Signup", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


}
