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

    private var viewModel = AddStockViewModel()

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
    func handleMarkAsFavourite(code: String) {
        // 관심 종목 추가에 대해서 동작함
        // 다만 앱 종료 후 다시 실행시 동작함
        let context = PersistenceManager.shared.context
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
        request.predicate = NSPredicate(format: "code = %@", code)
        do {
            guard let oldObjects = try context.fetch(request) as? [NSManagedObject] else {return}
            _ = oldObjects.map {
                $0.setValue(true, forKey: "star")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: 테이블뷰 셀 스와이프 액션 leading 추가
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let action = UIContextualAction(style: .normal, title: "Favorite") { [weak self] (_, _, completionHandler) in
//            self?.handleMarkAsFavourite()
//            completionHandler(true)
//        }
//        action.backgroundColor = .systemBlue
//        return UISwipeActionsConfiguration(actions: [action])
//    }
    // MARK: 테이블뷰 셀 스와이프 액션 traling 추가
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? AddStockViewCell, let code = cell.code else {return nil}
        let action = UIContextualAction(style: .normal, title: "추가") { [weak self] (_, _, completionHandler) in
            // escaping 같은 문법임
            // 동기적으로 순서가 보장되기 때문에 여기서 실행해야함.
            self?.handleMarkAsFavourite(code: code)
            self?.viewModel?.fetchData()
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [action])
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .none {
//
//        }
//
//    }
}
