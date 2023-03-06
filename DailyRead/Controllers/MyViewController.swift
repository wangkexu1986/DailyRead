//
//  MyViewController.swift
//  Daily Read
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit

class MyViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpView()
    }
    
    private func setUpView() {
        if let userName = UserDefaults.standard.string(forKey: LOGIN_USER_NAME) {
            self.userNameLabel.text = userName
        }
        self.logoutButton.layer.cornerRadius = 3
    }
    

    @IBAction func touchUpInsideLogout(_ sender: Any) {
        let alertViewController = UIAlertController.init(title: "", message: "alert_logout".localized(), preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction.init(title: "button_yes".localized(), style: .default, handler: {_ in
            UserDefaults.standard.removeObject(forKey: LOGIN_TOKEN_KEY)
            UserDefaults.standard.removeObject(forKey: LOGIN_USER_NAME)
            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: "My2Login", sender: nil)
        }))
        alertViewController.addAction(UIAlertAction.init(title: "button_no".localized(), style: .cancel, handler: nil))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func touchUpInsideCreateButton(_ sender: Any) {
        self.performSegue(withIdentifier: "My2Create", sender: nil)
    }
    
    
    @IBAction func touchUpInsideLookOver(_ sender: Any) {
        self.performSegue(withIdentifier: "My2LookOver", sender: nil)
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
