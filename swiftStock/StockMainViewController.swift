//
//  ViewController.swift
//  swiftStock
//
//  Created by 최광현 on 2020/12/16.
//

import UIKit
import Charts
import SnapKit

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
    private let serverURL : URL? = URL(string: "http://15.164.214.228:8000")
    
    let session = URLSession.shared
    var closePriceData : [[Double]] = []{
        didSet {
            DispatchQueue.main.async {
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
        // 테스트용 테이블 데이터 설정.
        self.setTableViewData()
        DispatchQueue.global().async {
            guard let url = self.serverURL?.appendingPathComponent("main") else {return}
            let codeList = (0..<self.tableData.count).map{
                return self.tableData[$0].companyCode
            }
            RequestSender.shared.send(url: url, httpMethod: .post, data: ["codes": codeList]){ (data) -> Void in
                guard let decodedData = try? JSONDecoder().decode([String:[[Double]]].self, from: data), let closePriceData = decodedData["closePrice"] else{
                    return
                }
                self.closePriceData = closePriceData
            }
        }
    }
    
    // MARK: setTableViewData 테이블 뷰 테스트 데이터
    func setTableViewData(){
        self.tableData.append(StockCode(code: "KOSPI", name: "코스피"))
        self.tableData.append(StockCode(code: "005930", name: "삼성전자"))
        self.tableData.append(StockCode(code: "035420", name: "NAVER"))
        self.tableData.append(StockCode(code: "035720", name: "카카오"))
        self.tableData.append(StockCode(code: "005380", name: "현대차"))
//        self.tableData.append(StockCode(code: "046310", name: "지니뮤직"))
//        self.tableData.append(StockCode(code: "AAPL", name: "Apple"))
//        self.tableData.append(StockCode(code: "TSLA", name: "Tesla"))
//        self.tableData.append(StockCode(code: "035720", name: "카카오"))
//        self.tableData.append(StockCode(code: "005380", name: "현대차"))
//        self.tableData.append(StockCode(code: "046310", name: "지니뮤직"))
    }
    
    // MARK: 서버에서부터 7일 전의 데이터를 받아오는 함수
    func getClosePrice(completionHandler: @escaping (Data) -> Void){
        
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
