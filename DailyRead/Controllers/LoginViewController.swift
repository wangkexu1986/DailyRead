//
//  LoginViewController.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
    }
    
    private func setUpView() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
        self.loginButton.layer.cornerRadius = 3
    }
    
    @objc private func tapView() {
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    @IBAction func touchUpInsideLogin(_ sender: Any) {
        let loginName = self.userNameTextField.text
        let loginPass = self.passwordTextField.text
        var parameters: [String: String] = [:]
        parameters["loginName"] = loginName
        parameters["loginPass"] = loginPass
        
        ProgressHUD.show("hud_login".localized(), interaction: true)
        LoginData.postLogin(parameters: parameters) { (object, userId, userName) in
            if object == "success" {
                ProgressHUD.showSuccess("hud_login_success".localized(), image: nil, interaction: true, delay: 1)
                self.navigationController?.dismiss(animated: true)
                self.saveUserToken(userId: userId)
                self.saveUserName(userName: userName)
                NotificationCenter.default.post(name: .NOTIFICATION_NAME_LOGIN, object: nil)
            } else if object == "failure" {
                ProgressHUD.showError("hud_login_failure".localized(), image: nil, interaction: true, delay: 1)
            }
        }
    }
    
    @IBAction func touchUpInsideRegister(_ sender: Any) {
        self.performSegue(withIdentifier: "Login2Register", sender: nil)
    }
    
    private func saveUserToken(userId: String?) {
        if let userId = userId {
            UserDefaults.standard.setValue(userId, forKey: LOGIN_TOKEN_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func saveUserName(userName: String?) {
        if let userName = userName {
            UserDefaults.standard.setValue(userName, forKey: LOGIN_USER_NAME)
            UserDefaults.standard.synchronize()
        }
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
