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

        view.backgroundColor = .otakuDark
            
            // Get the user's email from UserDefaults
            let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "Unknown"

            // Create the toast card container
            let profileCard = UIView()
            profileCard.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
            profileCard.layer.cornerRadius = 12
            profileCard.layer.borderWidth = 1.2
            profileCard.layer.borderColor = UIColor.otakuPink.cgColor
            profileCard.translatesAutoresizingMaskIntoConstraints = false

            // Avatar image
            let avatarImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
            avatarImage.tintColor = .otakuPink
            avatarImage.contentMode = .scaleAspectFit
            avatarImage.translatesAutoresizingMaskIntoConstraints = false

            // Email label
            let emailLabel = UILabel()
            emailLabel.text = userEmail
            emailLabel.textColor = .otakuGray
            emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            emailLabel.translatesAutoresizingMaskIntoConstraints = false

            // Add subviews to the card
            profileCard.addSubview(avatarImage)
            profileCard.addSubview(emailLabel)
            view.addSubview(profileCard)

            // Layout constraints
            NSLayoutConstraint.activate([
                profileCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                profileCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                profileCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
                profileCard.heightAnchor.constraint(equalToConstant: 80),

                avatarImage.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 16),
                avatarImage.centerYAnchor.constraint(equalTo: profileCard.centerYAnchor),
                avatarImage.widthAnchor.constraint(equalToConstant: 40),
                avatarImage.heightAnchor.constraint(equalToConstant: 40),

                emailLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 16),
                emailLabel.centerYAnchor.constraint(equalTo: profileCard.centerYAnchor),
                emailLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -16)
            ])
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
