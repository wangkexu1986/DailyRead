//
//  RegisterViewController.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var nickNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
    }
    
    private func setUpView() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
        self.registerButton.layer.cornerRadius = 3
    }
    
    @objc private func tapView() {
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.nickNameTextField.resignFirstResponder()
    }
    
    @IBAction func touchUpInsideRegister(_ sender: Any) {
        guard (nil != self.userNameTextField.text && self.userNameTextField.text!.count > 0) else {
            let alertViewController = UIAlertController.init(title: "", message: "alert_username_empty".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "button_confirm".localized(), style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
        }
        guard (nil != self.passwordTextField.text && self.passwordTextField.text!.count > 0) else {
            let alertViewController = UIAlertController.init(title: "", message: "alert_password_empty".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "button_confirm".localized(), style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
        }
        
        let loginName = self.userNameTextField.text
        let loginPass = self.passwordTextField.text
        var userNickName = ""
        if (nil != self.nickNameTextField.text && self.nickNameTextField.text!.count > 0) {
            userNickName = self.nickNameTextField.text ?? ""
        } else {
            userNickName = self.userNameTextField.text ?? ""
        }
        
        var parameters: [String: String] = [:]
        parameters["loginName"] = loginName
        parameters["loginPass"] = loginPass
        parameters["userNickName"] = userNickName
        
        ProgressHUD.show("hud_register".localized(), interaction: true)
        LoginData.postRegister(parameters: parameters) { object in
            if object == "success" {
                ProgressHUD.showSuccess("hud_register_success".localized(), image: nil, interaction: true, delay: 1)
                self.navigationController?.popViewController(animated: true)
            } else if object == "exist" {
                ProgressHUD.showError("hud_register_exist".localized(), image: nil, interaction: true, delay: 1)
            } else {
                ProgressHUD.showError("hud_register_failure".localized(), image: nil, interaction: true, delay: 1)
            }
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
