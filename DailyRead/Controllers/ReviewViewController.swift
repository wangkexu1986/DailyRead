//
//  ReviewViewController.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/27.
//

import UIKit
import MLAudioPlayer
import ProgressHUD

class ReviewViewController: UIViewController {

    var filePath: String = ""
    var essayContent: String = ""
    var essayId: String = ""
    var data: Data = Data()
    var isRead: Bool = false
    private var mlAudioPlayer: MLAudioPlayer = MLAudioPlayer.init()
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !self.isRead {
            try? FileManager.default.removeItem(atPath: self.filePath)
        }
    }
    
    func setUpView() {
        self.cancelButton.layer.cornerRadius = 3
        self.sendButton.layer.cornerRadius = 3
        let readTextView: UITextView = UITextView.init(frame: CGRect.init(x: 8, y: 90, width: self.view.frame.size.width - 16, height: 280))
        readTextView.text = self.essayContent
        readTextView.font = UIFont.boldSystemFont(ofSize: 16)
        readTextView.isEditable = false
        self.view.addSubview(readTextView)
        if isRead {
            self.sendButton.isHidden = true
            self.cancelButton.setTitle("button_close".localized(), for: .normal)
            self.showPlayerView(data: self.data)
        } else {
            self.showPlayerViewLocal(filePath: self.filePath)
        }
    }
    
    private func setupPlayer() {
        self.view.addSubview(mlAudioPlayer)
        mlAudioPlayer.backgroundColor = UIColor.init(white: 0.95, alpha: 0.9)
        mlAudioPlayer.layer.cornerRadius = 5
        NSLayoutConstraint.activate([
            mlAudioPlayer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mlAudioPlayer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  90)
            ])
    }
    
    private func showPlayerView(data: Data) {
        var config = MLPlayerConfig.init()
        config.playerType = .mini
        config.widthPlayerMini = 333
        mlAudioPlayer = MLAudioPlayer(urlAudio: filePath,data: data,
                                      config: config,
                                      isLocalFile: false, autoload: false)
        self.setupPlayer()
        NotificationCenter.default.post(name: .MLAudioPlayerNotification, object: nil,
                                        userInfo: ["action": MLPlayerActions.load])
    }
    
    private func showPlayerViewLocal(filePath: String) {
        var config = MLPlayerConfig.init()
        config.playerType = .mini
        config.widthPlayerMini = 333
        mlAudioPlayer = MLAudioPlayer(urlAudio: filePath,data: nil,
                                      config: config,
                                      isLocalFile: true, autoload: false)
        self.setupPlayer()
        NotificationCenter.default.post(name: .MLAudioPlayerNotification, object: nil,
                                        userInfo: ["action": MLPlayerActions.load])
    }
    
    @IBAction func touchUpInsideCancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func touchUpInsideSendButton(_ sender: Any) {
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: self.filePath))
            ProgressHUD.show("hud_uploading".localized(), interaction: true)
            ReadRecordData.uploadReadRecord(fileData: data) { result, fileName in
                if result == "success" {
                    var parameters: [String: Any] = [:]
                    parameters["essayId"] = self.essayId
                    parameters["readRecordName"] = fileName
                    parameters["createUser"] = UserDefaults.standard.string(forKey: LOGIN_TOKEN_KEY)!
                    parameters["updateUser"] = UserDefaults.standard.string(forKey: LOGIN_TOKEN_KEY)!
                    let i: Int = Int(self.mlAudioPlayer.totalDuration)
                    parameters["readRecordTime"] = String(describing: i)
                    ReadRecordData.postCreateReadRecord(parameters: parameters) { result in
                        if result == "success" {
                            ProgressHUD.showSuccess("hud_upload_success".localized(), image: nil, interaction: true, delay: 1)
                            self.dismiss(animated: true)
                            NotificationCenter.default.post(name: .NOTIFICATION_RECORD_FINISHED, object: nil)
                        } else {
                            ProgressHUD.showError("hud_upload_failure".localized(), image: nil, interaction: true, delay: 1)
                        }
                    }
                }
            }
        } catch {
            let alertViewController = UIAlertController.init(title: "", message: "alert_convert_error".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "button_confirm".localized(), style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
        }
    }
    
}
