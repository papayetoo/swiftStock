//
//  ViewController.swift
//  swiftStock
//
//  Created by 최광현 on 2020/12/16.
//

import UIKit
import Charts
import SnapKit

class ViewController: UIViewController {
    
    // MARK: LineChartView 연습
    lazy var lineChartsView: LineChartView = {
       let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
    
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
    
    
    let session = URLSession.shared
    var closePriceData : [[Double]] = []{
        didSet {
            DispatchQueue.main.async {
//                print("didSet", self.closePriceData)
                self.stockCodeTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(self.stockCodeTableView)
        self.stockCodeTableView.snp.makeConstraints({
            $0.leading.trailing.top.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(0)
        })
        
        DispatchQueue.global().async {
            self.setTableViewData()
            self.getClosePrice { data in
                guard let decodedData = try? JSONDecoder().decode([String:[[Double]]].self, from: data) else{return}
                guard let closePriceData = decodedData["closePrice"] else{return}
                print(closePriceData)
                self.closePriceData = closePriceData
            }
        }
    }
    
    // MARK: setTableViewData 테이블 뷰 테스트 데이터
    func setTableViewData(){
        self.tableData.append(StockCode(code: "005930", name: "삼성전자"))
        self.tableData.append(StockCode(code: "035420", name: "NAVER"))
        self.tableData.append(StockCode(code: "035720", name: "카카오"))
        self.tableData.append(StockCode(code: "005380", name: "현대차"))
    }
    
    // MARK: 서버에서부터 7일 전의 데이터를 받아오는 함수
    func getClosePrice(completionHandler: @escaping (Data) -> Void){
        print("getClosePrice")
        let serverURL = URL(string: "http://15.164.214.228:8000")
        guard let requestURL = serverURL?.appendingPathComponent("main") else {return}
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 100)
        let codeList = (0..<self.tableData.count).map{
            return self.tableData[$0].companyCode
        }
        let jsonData = ["codes": codeList]
        
        do{
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Mobile/iPhone", forHTTPHeaderField: "User-Agent")
            request.httpBody = try JSONEncoder().encode(codeList)
        }catch (let err){
            print(err.localizedDescription)
        }
        
        let requestTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                print(error?.localizedDescription)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                return
            }
            
            completionHandler(data)
        }
        
        requestTask.resume()
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

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.tableData.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if self.closePriceData.count == 0 {return UITableViewCell()}
        guard let cell = self.stockCodeTableView.dequeueReusableCell(withIdentifier: "StockCode") as? StockTableViewCell else{return UITableViewCell()}
//        cell.backgroundColor = UIColor.systemBlue
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        cell.backgroundColor = .white
        cell.nameLabel.text = self.tableData[indexPath.section].companyName
        cell.codeLabel.text = self.tableData[indexPath.section].companyCode
        
//        let cell.chartdataEntry = (0..<10).map{
//            return ChartDataEntry(x: Double($0), y: Double($0 * 2))
//        }
//        cell.chartDataEntry = (0..<10).map{ (i) -> ChartDataEntry in
//                return ChartDataEntry(x: Double(i), y: Double(i * 2))
//        }
//        let dataSet = ChartDataSet(entries: dataEntry)
//        let data = ChartData(dataSet: dataSet)
//        cell.closePriceChartView.data = data

        if self.closePriceData.count > indexPath.section{
            print("reload_data")
            let currentClosePriceData = self.closePriceData[indexPath.section]
            cell.chartDataEntry = (0..<currentClosePriceData.count).map{
                return ChartDataEntry(x: Double($0), y: currentClosePriceData[$0])
            }
        }
        return cell
    }
    
    // MARK: 테이블 섹션 수 정하는 함수 - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stockChartViewController = StockChartViewController()
        stockChartViewController.stockCode = StockCode(code: self.tableData[indexPath.section].companyCode, name: self.tableData[indexPath.section].companyCode)
        self.present(stockChartViewController, animated: false, completion: nil)
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
        return 250
    }
}

extension ViewController : ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        print(highlight)
    }
    
}
