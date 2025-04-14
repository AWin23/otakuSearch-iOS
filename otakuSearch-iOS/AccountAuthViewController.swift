//
//  AccountAuthViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/3/25.
//

import UIKit

class AccountAuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        // Checks if the user is logged
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        // load the storyboard instance of ProfileViewController
        if isLoggedIn {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            navigationController?.setViewControllers([profileVC], animated: false)
        }


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
