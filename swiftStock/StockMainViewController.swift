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
        tableView.backgroundColor = UIColor.white
        // tableView 구분선 스타일 결정
        tableView.separatorStyle = .none
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCode")
        return tableView
    }()

    lazy var tableData: [StockCode] = []
    private let serverURL: URL? = URL(string: "http://3.34.96.176:8000")
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
        // Do any additional setup after loading the
        self.view.backgroundColor = .systemBackground
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTouchUp(_:)))
        self.view.addSubview(self.stockCodeTableView)
        self.stockCodeTableView.snp.makeConstraints({
            $0.leading.trailing.top.bottom.equalTo(self.view).offset(0)
            $0.width.equalTo(self.view.frame.width)
        })
        // 테스트용 테이블 데이터 설정.
        self.setTableViewData()
        // 서버에서 데이터 수신
        // self.fetchData()

        let context = PersistenceManager.shared.persistanceContainer.viewContext
        let delAllReq = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo"))
        do {
            try context.execute(delAllReq)
        } catch {
            print(error)
        }

//        self.fetchStockInfo()
    }

    // MARK: setTableViewData 테이블 뷰 테스트 데이터
    func setTableViewData() {
        self.tableData.append(StockCode(code: "KOSPI", name: "코스피"))
        self.tableData.append(StockCode(code: "005930", name: "삼성전자"))
        self.tableData.append(StockCode(code: "035420", name: "NAVER"))
        self.tableData.append(StockCode(code: "035720", name: "카카오"))
        self.tableData.append(StockCode(code: "005380", name: "현대차"))
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
                // MARK: NSManagedObject를 만든다.
                let stockInfo = NSManagedObject(entity: entity, insertInto: context)
                if csvData.count > 2 {
                    stockInfo.setValue(csvData[1], forKey: "code")
                    stockInfo.setValue(csvData[2], forKey: "name")
                    print(csvData)
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

    func fetchStockInfo() {
        let context = PersistenceManager.shared.persistanceContainer.viewContext
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
            request.predicate = NSPredicate(format: "code = %@", "005930")
            guard let data = try context.fetch(request) as? [StockInfo] else {return}
            print(data[0].name)
        } catch {
            print(error.localizedDescription)
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
//        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.stockCodeTableView.dequeueReusableCell(withIdentifier: "StockCode") as? StockTableViewCell else {return UITableViewCell()}
        cell.backgroundColor = .white
        cell.nameLabel.text = self.tableData[indexPath.row].companyName
        cell.codeLabel.text = self.tableData[indexPath.row].companyCode
        if self.closePriceData.count > indexPath.row {
            let currentClosePriceData = self.closePriceData[indexPath.row]
            cell.chartDataEntry = (0..<currentClosePriceData.count).map {
                return ChartDataEntry(x: Double($0), y: currentClosePriceData[$0])
            }
            guard let lastData = currentClosePriceData.last else {return cell}
            cell.currentPrice  = lastData
            let beforeLastData = currentClosePriceData[currentClosePriceData.endIndex - 2]
            cell.percent = (lastData - beforeLastData) / beforeLastData
            if lastData >= beforeLastData {
                cell.isIncreasing = true
            } else {
                cell.isIncreasing = false
            }
        }
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
        return CGFloat(10)
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableData.remove(at: indexPath.row)
            self.stockCodeTableView.reloadData()
        }
    }
}

extension StockMainViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        print(highlight)
    }
}
