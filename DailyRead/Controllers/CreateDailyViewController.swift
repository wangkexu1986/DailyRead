//
//  CreateDailyViewController.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/23.
//

import UIKit
import ProgressHUD
import AVFAudio
import AVFoundation

class CreateDailyViewController: UIViewController {
    private var mlAudioPlayer: MLAudioPlayer = MLAudioPlayer.init()
    private var recordFileDirectory = ""
    private var subRecordFileNames: [String] = []
    private var recordPannelView: UIView!
    private var lab_recordTime: UILabel = UILabel.init()
    private var stopButton: UIButton = UIButton.init()
    private var currentFilePath: String = ""
    private var isCancelMode = false
    var readTextView: UITextView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var recordImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for path in self.subRecordFileNames {
            do {
                try? FileManager.default.removeItem(atPath: path)
            } catch {
                
            }
        }
    }
    
    private func setUpView() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapView))
        tap.isEnabled = true
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
        
        self.textField.placeholder = "placeholder_input_size50".localized()
        self.textView.delegate = self
        self.textView.text = "placeholder_input_size".localized()
        self.recordPannelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.recordPannelView.center = CGPoint.init(x: self.view.bounds.width / 2.0, y: self.view.bounds.height/2.0)
        self.recordPannelView.backgroundColor = UIColor.init(white: 1.0, alpha: 1)
        self.recordPannelView.layer.cornerRadius = 5.0
        var window: UIWindow?
        if #available(iOS 15.0, *) {
            window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow
        } else {
            // Fallback on earlier versions
            window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
        }
        window?.addSubview(self.recordPannelView)
        do{
            readTextView = UITextView.init(frame: CGRect.init(x: 8, y: 90, width: self.recordPannelView.frame.size.width - 16, height: 280))
            readTextView.font = UIFont.boldSystemFont(ofSize: 16)
            readTextView.isEditable = false
            self.recordPannelView.addSubview(readTextView)
            
            let lab_title = UILabel.init(frame: CGRect.init(x: 0, y: self.recordPannelView.bounds.height/2.0, width: self.recordPannelView.bounds.width, height: 20))
            lab_title.text = "title_recording".localized()
            lab_title.font = UIFont.systemFont(ofSize: 16)
            lab_title.textColor = .black
            lab_title.textAlignment = .center
            self.recordPannelView.addSubview(lab_title)
            
            self.lab_recordTime.frame = CGRect.init(x: 0, y: self.recordPannelView.bounds.height/2.0 + 35, width: self.recordPannelView.bounds.width, height: 30)
            self.lab_recordTime.textAlignment = .center
            self.lab_recordTime.font = UIFont.systemFont(ofSize: 24)
            self.lab_recordTime.text = "00:00"
            self.lab_recordTime.textColor = .black
            self.recordPannelView.addSubview(self.lab_recordTime)
            
            self.stopButton.frame = CGRect.init(x: 0, y: self.recordPannelView.bounds.height/2.0 + 100, width: 50, height: 50)
            self.stopButton.center.x = self.recordPannelView.bounds.width / 2.0
            self.stopButton.tintColor = UIColor.black
            self.stopButton.setImage(UIImage.init(named: "stop_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.recordPannelView.addSubview(self.stopButton)
            self.stopButton.addTarget(self, action: #selector(self.touchUpInsideStopButton(_:)), for: .touchUpInside)
            self.recordPannelView.isHidden = true
        }
    }
    
    @objc private func tapView() {
        self.textField.resignFirstResponder()
        self.textView.resignFirstResponder()
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
    
    @objc private func touchUpInsideStopButton(_ sender: Any) {
        print("结束录音")
        self.recordPannelView.isHidden = true
        self.recordImageView.isHidden = true
        self.recordButton.setTitle("button_cancel".localized(), for: .normal)
        self.isCancelMode = true
        self.lab_recordTime.text = "00:00"
        RecorderManager.sharedInstance.stopRecording()
    }
    
    private func checkMicroPermission() -> Bool{
        let mediaType = AVMediaType.audio
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch authorizationStatus {
        case .notDetermined:  //用户尚未做出选择
            return false
        case .authorized:  //已授权
            return true
        case .denied:  //用户拒绝
            return false
        case .restricted:  //家长控制
            return false
        }
    }
    
    private func openPermissions(){
        let settingUrl = NSURL(string: UIApplication.openSettingsURLString)!
        if UIApplication.shared.canOpenURL(settingUrl as URL)
        {
            UIApplication.shared.open(settingUrl as URL, options: [:], completionHandler: { (istrue) in
                
            })
        }
    }

    @IBAction func touchUpInsideRecordButton(_ sender: Any) {
        if !self.checkMicroPermission() {
            let alertViewController = UIAlertController.init(title: "", message: "alert_mic_permission".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "button_jump".localized(), style: .default, handler: { action in
                self.openPermissions()
            }))
            alertViewController.addAction(UIAlertAction.init(title: "button_cancel".localized(), style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
        }
        
        if self.isCancelMode {
            for path in self.subRecordFileNames {
                try? FileManager.default.removeItem(atPath: path)
            }
            self.subRecordFileNames.removeAll()
            self.isCancelMode = false
            self.currentFilePath = ""
            self.recordButton.setTitle("button_record".localized(), for: .normal)
            self.recordImageView.isHidden = false
            self.mlAudioPlayer.removeFromSuperview()
        } else {
            print("开始录音")
            self.textView.resignFirstResponder()
            if self.textView.text == "placeholder_input_size".localized() {
                readTextView.text = ""
            } else {
                readTextView.text = self.textView.text!
            }
            self.recordPannelView.isHidden = false
            RecorderManager.sharedInstance.record { (timeInterval) in
                print("..timeInterval",timeInterval)

                let minute = Int(timeInterval / 60)
                let secord = Int(timeInterval.truncatingRemainder(dividingBy: 60.0))

                self.lab_recordTime.text = (minute > 9 ? "\(minute)" : "0\(minute)") + ":" + (secord > 9 ? "\(secord)" : "0\(secord)")
            } finishedHandle: { (totalTime, cacheFilePath) in
                print("总时长：",totalTime)
                print("文件路径：",cacheFilePath)
                
                if totalTime < 2 {
                    let tmpAlertViewController = UIAlertController.init(title: "", message: "alert_too_short".localized(), preferredStyle: .alert)
                    tmpAlertViewController.addAction(UIAlertAction.init(title: "button_close".localized(), style: .default, handler: nil))
                    self.present(tmpAlertViewController, animated: true, completion: nil)
                    try? FileManager.default.removeItem(atPath: cacheFilePath)
                }
                else {
                    self.subRecordFileNames.append(cacheFilePath)
                    self.currentFilePath = cacheFilePath
                    self.showPlayerView(filePath: cacheFilePath)
                }
            }
        }
    }
    
    private func showPlayerView(filePath: String) {
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
    
    @IBAction func touchUpInsideSendButton(_ sender: Any) {
        guard self.textField.text!.count > 0 && self.textView.text.count > 0 && self.currentFilePath.count > 0 else {
            let alertViewController = UIAlertController.init(title: "", message: "alert_record_please".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
        }
        guard self.textView.text.count < 300 && self.textField.text!.count < 50 else {
            let alertViewController = UIAlertController.init(title: "", message: "alert_oversize".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "button_confirm".localized(), style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
        }
        
        var parameters: [String: Any] = [:]
        parameters["essayContent"] = self.textView.text ?? ""
        parameters["essayTitle"] = self.textField.text ?? ""
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: self.currentFilePath))
            ProgressHUD.show("hud_uploading".localized(), interaction: true)
            EssayData.uploadEssayRecord(fileData: data) { (result, fileName) in
                if result == "success" {
                    parameters["essayRecord"] = fileName
                    parameters["createUser"] = UserDefaults.standard.string(forKey: LOGIN_TOKEN_KEY)
                    parameters["updateUser"] = UserDefaults.standard.string(forKey: LOGIN_TOKEN_KEY)
                    EssayData.postCreateEssay(parameters: parameters) { result in
                        if result == "success" {
                            ProgressHUD.showSuccess("hud_upload_success".localized(), image: nil, interaction: true, delay: 1)
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            ProgressHUD.showError("hud_upload_failure".localized(), image: nil, interaction: true, delay: 1)
                        }
                    }
                }
            }
        }
        catch {
            let alertViewController = UIAlertController.init(title: "", message: "alert_convert_error".localized(), preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "button_confirm".localized(), style: .cancel, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
            return
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

extension CreateDailyViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "placeholder_input_size".localized() {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "placeholder_input_size".localized()
            textView.textColor = UIColor.systemGray3
        }
    }
}
