//
//  HomeViewController.swift
//  Daily Read
//
//  Created by 王克旭 on 2023/2/21.
//

import UIKit
import PullToRefreshKit

let LOGIN_TOKEN_KEY: String = "LOGIN_TOKEN_KEY"
let LOGIN_USER_NAME: String = "LOGIN_USER_NAME"

class HomeViewController: UIViewController {
    private var homeListData: [HomeListData] = []
    private let pageSize: Int = 20
    private var pageNumber: Int = 1
    
    @IBOutlet weak var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.checkLogin()
    }
    
    func checkLogin() {
        if nil == UserDefaults.standard.string(forKey: LOGIN_TOKEN_KEY) {
            self.performSegue(withIdentifier: "Home2Login", sender: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.setUpView), name: .NOTIFICATION_NAME_LOGIN, object: nil)
        } else {
            self.setUpView()
        }
    }
    
    @objc func setUpView() {
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        self.setUpData(pageNumber: self.pageNumber)
        self.homeTableView.configRefreshHeader(container:self) { [weak self] in
            self?.pageNumber = 1
            self?.homeListData.removeAll()
            self?.setUpData(pageNumber: 1)
        }
    }
    
    func setUpData(pageNumber: Int) {
        var parameters: [String: Any] = [:]
        parameters["pageNumber"] = pageNumber
        HomeListData.getHomeList(parameters: parameters) { object in
            if let obj = object {
                self.homeListData += obj
            }
            self.homeTableView.switchRefreshHeader(to: .normal(.success, 0.5))
            self.homeTableView.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeListData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.CellIndentifier) as? HomeTableViewCell
        if cell == nil {
            let nibArray = Bundle.main.loadNibNamed(HomeTableViewCell.CellIndentifier, owner: self, options: nil)
            cell = nibArray?.first as? HomeTableViewCell
        }
        let homeList = self.homeListData[indexPath.row]
        cell?.dateLabel.text = homeList.date
        cell?.titleLabel.text = homeList.title
        cell?.writerLabel.text = homeList.writer
        cell?.selectionStyle = .none
        if (indexPath.row == self.pageNumber * pageSize) {
            self.pageNumber += 1
            self.setUpData(pageNumber: self.pageNumber)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Home2DailyContent", sender: indexPath.row)
    }
}

extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Home2DailyContent" {
            let contentViewController = segue.destination as! DailyContentViewController
            let index: Int = sender as! Int
            let data = self.homeListData[index]
            contentViewController.essayId = data._id
        }
    }
}

extension Notification.Name {
    public static let NOTIFICATION_NAME_LOGIN = Notification.Name("NOTIFICATION_NAME_LOGIN")
    public static let NOTIFICATION_RECORD_FINISHED = Notification.Name("NOTIFICATION_RECORD_FINISHED")
}
