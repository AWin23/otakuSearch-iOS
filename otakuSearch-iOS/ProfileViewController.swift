//
//  ProfileViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/3/25.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 🔗 Connect this IBAction to your "Logout" button in storyboard
    @IBAction func logoutTapped(_ sender: UIButton) {
        print("📤 Logging out...")

        // 1. Clear UserDefaults keys
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "loggedInEmail")
        UserDefaults.standard.synchronize()

        // 2. Show alert confirmation
        let alert = UIAlertController(title: "Logged Out", message: "You’ve been signed out.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Optionally go to login screen or refresh UI
            self.redirectToLogin()
        })
        present(alert, animated: true)
    }

    // Optional helper to redirect
    func redirectToLogin() {
        performSegue(withIdentifier: "goToAuthScreen", sender: self)
    }
    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//

}
