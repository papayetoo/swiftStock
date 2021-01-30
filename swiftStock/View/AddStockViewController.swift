//
//  AddStockViewController.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/27.
//

import UIKit
import CoreData
import SnapKit

class AddStockViewController: UIViewController {

    private let viewModel = AddStockViewModel()

    private let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(AddStockViewCell.self, forCellReuseIdentifier: "stock")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setTableLayout()
    }

    func setTableLayout() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(self.view)
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

extension AddStockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.viewModel?.stockInfoData?.count else {
            return 0
        }
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "stock", for: indexPath) as? AddStockViewCell,
              let data = self.viewModel?.stockInfoData?[indexPath.row] else {return UITableViewCell()}
        cell.name = data.name
        cell.code = data.code
        return cell
    }
}

extension AddStockViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
