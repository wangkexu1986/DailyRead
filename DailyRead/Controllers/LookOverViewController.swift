//
//  LookOverViewController.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/28.
//

import UIKit

class LookOverViewController: UIViewController {
    private var homeListData: [HomeListData] = []
    private let pageSize: Int = 20
    private var pageNumber: Int = 1
    @IBOutlet weak var lookOverTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
    }
    
    @objc func setUpView() {
        self.lookOverTableView.delegate = self
        self.lookOverTableView.dataSource = self
        self.setUpData(pageNumber: self.pageNumber)
        self.lookOverTableView.configRefreshHeader(container:self) { [weak self] in
            self?.pageNumber = 1
            self?.homeListData.removeAll()
            self?.setUpData(pageNumber: 1)
        }
    }
    
    func setUpData(pageNumber: Int) {
        var parameters: [String: Any] = [:]
        parameters["pageNumber"] = pageNumber
        if let userId = UserDefaults.standard.string(forKey: LOGIN_TOKEN_KEY) {
            parameters["userId"] = userId
        }
        HomeListData.getHomeList(parameters: parameters) { object in
            if let obj = object {
                self.homeListData += obj
            }
            self.lookOverTableView.switchRefreshHeader(to: .normal(.success, 0.5))
            self.lookOverTableView.reloadData()
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

extension LookOverViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeListData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        
        if (indexPath.row == self.pageNumber * pageSize) {
            self.pageNumber += 1
            self.setUpData(pageNumber: self.pageNumber)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "LookOver2Daily", sender: indexPath.row)
    }
}

extension LookOverViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contentViewController = segue.destination as! DailyContentViewController
        let index: Int = sender as! Int
        let data = self.homeListData[index]
        contentViewController.essayId = data._id
        contentViewController.isLookOver = true
    }
}
