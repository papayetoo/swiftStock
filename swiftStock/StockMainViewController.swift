//
//  ViewController.swift
//  swiftStock
//
//  Created by 최광현 on 2020/12/16.
//

import UIKit
import Charts
import SnapKit
import CoreData

class StockMainViewController: UIViewController {

    // MARK: 종목코드를 표현하기 위한 TableView
    lazy var stockCodeTableView: UITableView = {
        let tableView = UITableView()
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isOpaque = false
        tableView.backgroundColor = .clear
        // tableView 구분선 스타일 결정
        tableView.separatorStyle = .none
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCode")
        return tableView
    }()

    lazy var tableData: [StockCode] = []
    private let serverURL: URL? = URL(string: "http://3.34.192.214:8000")
    var closePriceData: [[Double]] = [] {
        didSet {
            DispatchQueue.main.async {
                self.stockCodeTableView.reloadData()
            }
        }
    }

    private let searchBar: UISearchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the uiview
        print("view Did load")
        self.view.backgroundColor = UIColor(red: 123/255, green: 19/255, blue: 242/255, alpha: 0.95)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTouchUp(_:)))
        self.view.addSubview(self.stockCodeTableView)
        self.stockCodeTableView.snp.makeConstraints({
            $0.leading.trailing.top.bottom.equalTo(self.view).offset(0)
            $0.width.equalTo(self.view.frame.width)
        })
//        self.unstarStockInfo(nameToUpdate: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        // Core Data에서 좋아요 표시된 데이터 가져옴.
        print("viewWillAppear")
        self.fetchFromCoreData()
        _ = self.tableData.map {
            print($0.companyName)
        }
        // 서버에서 데이터 수신
    }

    // MARK: 서버에서 종가 데이터 받아오는 코드
    func fetchData() {
        // 데이터는 데몬 쓰레드에서 데이터 가져옴.
        DispatchQueue.global().async {
            // server의 URL이 존재하는 상태라면...
            guard let url = self.serverURL?.appendingPathComponent("main") else {return}
            let codeList = self.tableData.map {return $0.companyCode}
            RequestSender.shared.send(url: url, httpMethod: .post, data: ["codes": codeList]) { (data) -> Void in
                guard let decodedData = try? JSONDecoder().decode([String: [[Double]]].self, from: data), let closePriceData = decodedData["closePrice"] else {
                    return
                }
                self.closePriceData = closePriceData
            }
        }
    }
    // MARK: csv Data 읽기
    func getCSVData() -> [String] {
        let context = PersistenceManager.shared.persistanceContainer.viewContext
        // MARK: entity를 가져온다.
        guard let entity = NSEntityDescription.entity(forEntityName: "StockInfo", in: context) else {return []}
        do {
            guard let path = Bundle.main.path(forResource: "codes", ofType: ".csv") else {return []}
            let contents = try String(contentsOfFile: path)
            _ = contents.components(separatedBy: "\n").map {
                let csvData = $0.components(separatedBy: ",")
                let stockInfo = NSManagedObject(entity: entity, insertInto: context)
                if csvData.count > 2 {
                    stockInfo.setValue(csvData[1], forKey: "code")
                    stockInfo.setValue(csvData[2], forKey: "name")
                    stockInfo.setValue(false, forKey: "star")
                }
            }
            try context.save()
            print("context end")
        } catch {
            print(error.localizedDescription)
            return []
        }
        return []
    }

    func updateStockInfo(codes: [String]) {
        let context = PersistenceManager.shared.context
        _ = codes.map {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
            do {
                request.predicate = NSPredicate(format: "code = %@", $0)
                let fetchObject = try context.fetch(request)
                let objToUpdate = fetchObject[0] as? NSManagedObject
                objToUpdate?.setValue(true, forKey: "star")
                try context.save()
                print("update StockInfo star column end.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func fetchFromCoreData() {
        let context = PersistenceManager.shared.context
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
        request.predicate = NSPredicate(format: "star == %@", NSNumber(booleanLiteral: true))
        DispatchQueue.global().async {
            do {
                guard let fetchedStockInfo = try context.fetch(request) as? [StockInfo] else {return}
                self.tableData = fetchedStockInfo.map { StockCode(code: $0.code!, name: $0.name!)}
                DispatchQueue.main.async {
                    self.stockCodeTableView.reloadData()
                }
//                self.fetchData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func unstarStockInfo(nameToUpdate: String?) {
        let context = PersistenceManager.shared.context
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
        if nameToUpdate != nil {
            request.predicate = NSPredicate(format: "name = %@", nameToUpdate!)
        }
        do {
            guard let oldObjects = try context.fetch(request) as? [NSManagedObject] else {return}
            oldObjects.map {
                $0.setValue(false, forKey: "star")
            }
            try context.save()
        } catch {
            print(error)
        }
    }

    @objc func addButtonTouchUp(_ sender: Any) {
        print("touch UP inside")
        let addStockViewController = AddStockViewController()
        self.navigationController?.pushViewController(addStockViewController, animated: false)
    }
}

extension UIColor {
    // MARK: HEX COLOR를 rgb로 변환하기 위한 작업.
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue), alpha: CGFloat(a) / 255.0)
    }

    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}

extension StockMainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.stockCodeTableView.dequeueReusableCell(withIdentifier: "StockCode") as? StockTableViewCell else {return UITableViewCell()}
        cell.backgroundColor = .clear
        cell.nameLabel.text = self.tableData[indexPath.row].companyName
//        cell.codeLabel.text = self.tableData[indexPath.row].companyCode
        _ = self.closePriceData.map {_ in
            let currentClosePriceData = self.closePriceData[indexPath.row]
            cell.chartDataEntry = currentClosePriceData.enumerated().map {
                return ChartDataEntry(x: Double($0), y: $1)
            }
            guard let lastClosePriceData = currentClosePriceData.last else {return}
            cell.currentPrice = lastClosePriceData
            let beforeLastClostPriceData = currentClosePriceData[currentClosePriceData.endIndex - 2]
            cell.isIncreasing = lastClosePriceData > beforeLastClostPriceData ? true : false
            cell.percent = (lastClosePriceData - beforeLastClostPriceData) / beforeLastClostPriceData
        }
//        if self.closePriceData.count > indexPath.row {
//            let currentClosePriceData = self.closePriceData[indexPath.row]
//            cell.chartDataEntry = (0..<currentClosePriceData.count).map {
//                return ChartDataEntry(x: Double($0), y: currentClosePriceData[$0])
//            }
//            guard let lastData = currentClosePriceData.last else {return cell}
//  cell.currentPrice  = lastData
//            let beforeLastData = currentClosePriceData[currentClosePriceData.endIndex - 2]
//            cell.percent = (lastData - beforeLastData) / beforeLastData
//            if lastData >= beforeLastData {
//                cell.isIncreasing = true
//            } else {
//                cell.isIncreasing = false
//            }
//        }
        return cell
    }
    // MARK: 테이블 섹션 수 정하는 함수 - UITableViewDataSource
    // section 과 indexPath 구분할 것
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.tableData.count
//    }
}

extension StockMainViewController: UITableViewDelegate {
    // MARK: cell 선택시 액션
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stockChartViewController = StockChartViewController()
        stockChartViewController.stockCode = StockCode(code: self.tableData[indexPath.row].companyCode,
                                                       name: self.tableData[indexPath.section].companyCode)
        stockChartViewController.companyName = self.tableData[indexPath.row].companyName
        stockChartViewController.stockCode = self.tableData[indexPath.row]
        print(self.tableData)
        self.navigationController?.pushViewController(stockChartViewController, animated: false)
    }
    // MARK: cell 선택취소시 함수.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        return
    }
    // MARK: 섹션 헤더 높이 설정.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: "삭제") {
            [weak self] (_, _, completionHandler) in
            guard let nameToUpdate = self?.tableData[indexPath.row].companyName else {return}
            self?.tableData.remove(at: indexPath.row)
            // Invalid update: invalid number of rows in section 0 에러 발생 원인
            // 테이블 뷰에서 로우를 삭제한뒤 reloadData가 자동호출되는데 dataSource로 드렁온 객체와 갯수가 맞지 않아서
            // 발생하는 문제임. 문제를 해결하기 위해서는 tableData에서 먼저 삭제한 후에 row를 삭제하면 문제가 해결됨.
            tableView.deleteRows(at: [indexPath], with: .left)
            self?.unstarStockInfo(nameToUpdate: nameToUpdate)
            completionHandler(true)
        }
        action.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [action])
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            self.tableData.remove(at: indexPath.row)
//        }
//    }
}

extension StockMainViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        print(highlight)
    }
}
