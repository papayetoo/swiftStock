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
    lazy var stockCodeTableView : UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.white
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCode")
        return tableView
    }()

    lazy var tableData: [StockCode] = []
    private let serverURL : URL? = URL(string: "http://3.36.72.105:8000")
    var closePriceData : [[Double]] = []{
        didSet {
            DispatchQueue.main.async {
                self.stockCodeTableView.reloadData()
            }
        }
    }
    
    private let searchBar : UISearchBar = UISearchBar()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the
//        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(self.stockCodeTableView)
        self.stockCodeTableView.snp.makeConstraints({
            $0.leading.trailing.top.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(0)
        })
        // 테스트용 테이블 데이터 설정.
        self.setTableViewData()
//        let csvData = self.getCSVData()
        self.fetchStockInfo()
        // 주식 코드를 먼저 가지고 있을지?
        // MARK: 서버에서 종가 데이터 받아오는 코드
//        DispatchQueue.global().async {
//            guard let url = self.serverURL?.appendingPathComponent("main") else {return}
//            let codeList = (0..<self.tableData.count).map{
//                return self.tableData[$0].companyCode
//            }
//            RequestSender.shared.send(url: url, httpMethod: .post, data: ["codes": codeList]){ (data) -> Void in
//                guard let decodedData = try? JSONDecoder().decode([String:[[Double]]].self, from: data), let closePriceData = decodedData["closePrice"] else{
//                    return
//                }
//                self.closePriceData = closePriceData
//            }
//        }
    }
    
    // MARK: setTableViewData 테이블 뷰 테스트 데이터
    func setTableViewData(){
        self.tableData.append(StockCode(code: "KOSPI", name: "코스피"))
        self.tableData.append(StockCode(code: "005930", name: "삼성전자"))
        self.tableData.append(StockCode(code: "035420", name: "NAVER"))
        self.tableData.append(StockCode(code: "035720", name: "카카오"))
        self.tableData.append(StockCode(code: "005380", name: "현대차"))
    }
    // MARK: csv Data 읽기
    func getCSVData() -> Array<String> {
        let context = self.appDelegate.persistentContainer.viewContext
        // MARK: entity를 가져온다.
        guard let entity = NSEntityDescription.entity(forEntityName: "StockInfo", in: context) else{return []}
        do{
            guard let path = Bundle.main.path(forResource: "codes", ofType: ".csv") else{return []}
            let contents = try String(contentsOfFile: path)
            let _ = contents.components(separatedBy: "\n").map{
                let csvData = $0.components(separatedBy: ",")
                // MARK: NSManagedObject를 만든다.
                let stockInfo = NSManagedObject(entity: entity, insertInto: context)
                if csvData.count > 2{
                    stockInfo.setValue(csvData[1], forKey: "code")
                    stockInfo.setValue(csvData[2], forKey: "name")
                    print(csvData)
                }
            }
            try context.save()
            print("context end")
        }catch{
            print(error.localizedDescription)
            return []
        }
        return []
    }
    
    func fetchStockInfo(){
        let context = self.appDelegate.persistentContainer.viewContext
        
        do {
//            let data = try context.fetch(StockInfo.fetchRequest()) as! [StockInfo]
//            data.forEach{
//                print($0.name)
//            }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
            request.predicate = NSPredicate(format: "code = %@", "005930")
            let data = try context.fetch(request)
            print(data)
        }catch{
            print(error.localizedDescription)
        }
    }
}

extension UIColor {
    //  MARK: HEX COLOR를 rgb로 변환하기 위한 작업.
    convenience init(red: Int, green:Int, blue:Int, a: Int = 0xFF){
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue), alpha: CGFloat(a) / 255.0)
    }
    
    convenience init(rgb:Int){
        self.init(red: (rgb >> 16) & 0xFF, green : (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}

extension StockMainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.tableData.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if self.closePriceData.count == 0 {return UITableViewCell()}
        guard let cell = self.stockCodeTableView.dequeueReusableCell(withIdentifier: "StockCode") as? StockTableViewCell else{return UITableViewCell()}
//        cell.backgroundColor = UIColor.systemBlue
//        cell.layer.borderColor = UIColor.black.cgColor
//        cell.layer.borderWidth = 0.2
//        cell.layer.cornerRadius = 20
//        cell.clipsToBounds = true
        cell.backgroundColor = .white
        cell.nameLabel.text = self.tableData[indexPath.section].companyName
        cell.codeLabel.text = self.tableData[indexPath.section].companyCode
                
        if self.closePriceData.count > indexPath.section{
            let currentClosePriceData = self.closePriceData[indexPath.section]
            cell.chartDataEntry = (0..<currentClosePriceData.count).map{
                return ChartDataEntry(x: Double($0), y: currentClosePriceData[$0])
            }
            guard let lastData = currentClosePriceData.last else{return cell}
            let beforeLastData = currentClosePriceData[currentClosePriceData.endIndex - 2]
            if lastData >= beforeLastData {
                cell.isIncreasing = true
            }else{
                cell.isIncreasing = false
            }
        }
        return cell
    }
    
    // MARK: 테이블 섹션 수 정하는 함수 - UITableViewDataSource
    // section 과 indexPath 구분할 것
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
}

extension StockMainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stockChartViewController = StockChartViewController()
        stockChartViewController.stockCode = StockCode(code: self.tableData[indexPath.section].companyCode, name: self.tableData[indexPath.section].companyCode)
        // present를 push로 변경할 것.
        self.present(stockChartViewController, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension StockMainViewController : ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        print(highlight)
    }
    
}
