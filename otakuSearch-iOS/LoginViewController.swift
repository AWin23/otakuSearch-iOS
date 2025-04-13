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
            guard let data = data, error == nil else {
                print("Login failed:", error?.localizedDescription ?? "Unknown error")
                return
            }

            // Parse response JSON
            do {
                // Try to print the raw string response
                if let rawString = String(data: data, encoding: .utf8) {
                    print("🧾 Raw response:\n\(rawString)")
                }
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userId = json["userId"] as? Int,
                   let email = json["email"] as? String {
                    
                    // Save to UserDefaults
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(String(userId), forKey: "userId")
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    
                    print("✅ Logged in userId:", userId)
                    
                    // show the alert first and then dismiss it or transition after tapping "OK".
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success", message: "Login successful!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                            self.navigationController?.pushViewController(profileVC, animated: true)
                        }))
                        
                        self.present(alert, animated: true)
                    }


                } else {
                    print("❌ Could not parse user data from login response.")
                }
            } catch {
                print("❌ JSON parse error:", error.localizedDescription)
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
