//
//  DailyContentViewController.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit
import MLAudioPlayer
import PullToRefreshKit
import AVFAudio
import AVFoundation

class DailyContentViewController: UIViewController {
    private var mlAudioPlayer: MLAudioPlayer = MLAudioPlayer.init()
    
    @IBOutlet weak var dailyContentTableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var titleLabelView: UILabel!
    
    @IBOutlet weak var contentTextView: TextViewAutoHeight!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerView: UIView!
    var essayId: String = ""
    private var essayData: EssayData = EssayData()
    private var recordFileDirectory = ""
    private var subRecordFileNames: [String] = []
    private var recordPannelView: UIView!
    private var lab_recordTime: UILabel = UILabel.init()
    private var stopButton: UIButton = UIButton.init()
    private var isRecording: Bool = false
    private var pageNumber: Int = 1
    private let pageSize: Int = 20
    private var readRecordData: [ReadRecordData] = []
    var isLookOver: Bool = false
    var indicatorView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dailyContentTableView.configRefreshHeader(container:self) { [weak self] in
            self?.refreshRecordList()
        }
        self.setUpData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mlAudioPlayer.stop()
    }
    
    func setUpView() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshRecordList), name: .NOTIFICATION_RECORD_FINISHED, object: nil)
        
        indicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicatorView?.style = .medium
        indicatorView?.startAnimating()
        indicatorView?.center = self.view.center
        self.view.addSubview(indicatorView!)
        
        self.contentTextView.maxHeight = 280
        self.titleLabelView.text = self.essayData.essayTitle
        self.contentTextView.text = self.essayData.essayContent
        self.contentTextView.delegate = self
        var finalContentSize:CGSize = self.contentTextView.contentSize
        finalContentSize.width  += (self.contentTextView.textContainerInset.left + self.contentTextView.textContainerInset.right ) / 2.0
        finalContentSize.height += (self.contentTextView.textContainerInset.top  + self.contentTextView.textContainerInset.bottom) / 2.0
        
        self.headerView.frame.size.height = self.contentTextView.frame.origin.y +  finalContentSize.height  + 80
        
        self.recordButton.layer.cornerRadius = self.recordButton.bounds.height/2.0
        if isLookOver {
            self.recordButton.isHidden = true
        }
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
            let readTextView: UITextView = UITextView.init(frame: CGRect.init(x: 8, y: 90, width: self.recordPannelView.frame.size.width - 16, height: 280))
            readTextView.text = self.essayData.essayContent
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
        self.dailyContentTableView.delegate = self
        self.dailyContentTableView.dataSource = self
    }

    @objc private func setUpData() {
        var parameters: [String: Any] = [:]
        parameters["_id"] = self.essayId
        EssayData.getEssayContent(parameters: parameters) { (error, essay) in
            if nil == error {
                self.essayData = essay ?? EssayData()
                self.setUpView()
                
                let parameter = ["fileName": self.essayData.essayRecord]
                EssayData.downloadRecord(parameters: parameter) { error, data in
                    self.showPlayerView(data: data)
                    self.dailyContentTableView.reloadData()
                }
                
                self.getReacordList()
            }
        }
    }
    
    @objc private func refreshRecordList() {
        self.pageNumber = 1
        self.readRecordData.removeAll()
        self.getReacordList()
    }
    
    private func getReacordList() {
        let parameters: [String: Any] = ["essayId": self.essayData._id, "pageNumber": self.pageNumber]
        ReadRecordData.getReadRecordList(parameters: parameters) { readRecordList in
            if readRecordList.count > 0 {
                self.readRecordData += readRecordList
            }
            self.dailyContentTableView.switchRefreshHeader(to: .normal(.success, 0.5))
            self.dailyContentTableView.reloadData()
        }
    }
    
    private func setupPlayer() {
        self.headerView.addSubview(mlAudioPlayer)
        mlAudioPlayer.backgroundColor = UIColor.init(white: 0.95, alpha: 0.9)
        mlAudioPlayer.layer.cornerRadius = 5
        NSLayoutConstraint.activate([
            mlAudioPlayer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            mlAudioPlayer.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant:  self.headerView.center.y - 50)
            ])
    }
    
    private func showPlayerView(data: Data?) {
        indicatorView?.stopAnimating()
        var config = MLPlayerConfig.init()
        config.playerType = .mini
        config.widthPlayerMini = 333
        mlAudioPlayer = MLAudioPlayer(urlAudio: "", data: data,
                                      config: config,
                                      isLocalFile: false, autoload: false)
        self.setupPlayer()
        NotificationCenter.default.post(name: .MLAudioPlayerNotification, object: nil,
                                        userInfo: ["action": MLPlayerActions.load])
    }
    
    @objc private func touchUpInsideStopButton(_ sender: Any) {
        print("结束录音")
        self.recordPannelView.isHidden = true
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
            print("开始录音")
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
                    self.performSegue(withIdentifier: "Content2Review", sender: (cacheFilePath, self.essayData.essayContent, self.essayData._id, Data(), false))
                }
            }
    }
}

extension DailyContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.readRecordData.count
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.contentTextView.frame.origin.y + self.textViewHeight.constant + 60
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: DailyContentTableViewCell.CellIndentifier) as? DailyContentTableViewCell
        if cell == nil {
            let nibArray = Bundle.main.loadNibNamed(DailyContentTableViewCell.CellIndentifier, owner: self, options: nil)
            cell = nibArray?.first as? DailyContentTableViewCell
        }
        let record = self.readRecordData[indexPath.row]
        cell?.userNameLabel.text = record.userName
        cell?.timeStampLabel.text = record.postDate
        cell?.filePath = record.readRecord
        var timeString: String = ""
        if let i: Int = Int(record.recordTime) {
            if i >= 60 {
                let minut: Int = i / 60
                let second = i % 60
                timeString = String(minut) + "'" + String(second) + "\""
            } else {
                let second = String(i)
                timeString = second + "\""
            }
        }
        cell?.bubbleButton.setTitle(timeString, for: .normal)
        cell?.buttonCallBack = { (cell) in
            let parameter = ["fileName": record.readRecord]
            EssayData.downloadRecord(parameters: parameter) { error, data in
                if nil == error {
                    self.performSegue(withIdentifier: "Content2Review", sender: ("", self.essayData.essayContent, self.essayData._id, data, true))
                }
            }
        }
        
        if (indexPath.row == pageSize) {
            self.pageNumber += 1
            self.getReacordList()
        }
        return cell!
    }
}

extension DailyContentViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tuple: (String, String, String, Data, Bool) = sender as! (String, String, String, Data, Bool)
        let filePath: String = tuple.0
        let essayContent = tuple.1
        let essayId = tuple.2
        let data = tuple.3
        let isRead = tuple.4
        let reviewController = segue.destination as! ReviewViewController
        reviewController.filePath = filePath
        reviewController.essayContent = essayContent
        reviewController.essayId = essayId
        reviewController.data = data
        reviewController.isRead = isRead
    }
}

extension DailyContentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
    }
}
