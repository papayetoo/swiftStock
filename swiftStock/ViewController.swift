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
    
    // MARK: CandleStickChartView 그리기 위함.
    lazy var candleStickChartView : CandleStickChartView = {
        let chartView = CandleStickChartView()
        chartView.backgroundColor = .white
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.orientation = .vertical
        chartView.legend.drawInside = false
        chartView.drawGridBackgroundEnabled = false
        if let font = UIFont(name: "Helevetica-Nueue", size: 10){
            chartView.legend.font = font
        }
        chartView.backgroundColor = .black
        
        chartView.drawGridBackgroundEnabled = false
        return chartView
    }()
    
    
    // MARK: 종목코드를 표현하기 위한 TableView
    lazy var stockCodeTableView : UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: "StockCode")
        return tableView
    }()

    var candleData : [CandleChartDataEntry] = []
    
    // AWS EC2 server와 HTTP 통신하기 위한 session
    let session: URLSession = URLSession(configuration: .default)
    
    lazy var tableData: [StockCode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let mainBackgroundColor = UIColor(rgb: 0xE7FDDF)
        self.view.backgroundColor = mainBackgroundColor
        self.view.addSubview(self.stockCodeTableView)
        self.stockCodeTableView.snp.makeConstraints({
            $0.leading.trailing.top.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(0)
        })
        
        self.setTableViewData()
        
        // MARK: candlestickChartView 테스트 코드
//        self.view.addSubview(self.candleStickChartView)
//        self.candleStickChartView.snp.makeConstraints({
//            $0.leading.trailing.equalTo(self.view).offset(0)
//            $0.top.equalTo(self.view).offset(0)
//            $0.bottom.equalTo(self.view).offset(0)
//        })
//
//        self.candleStickChartView.delegate = self
//        self.stockPost()
    }
    
    func setTableViewData(){
        self.tableData.append(StockCode(code: "005930", name: "삼성전자"))
        self.tableData.append(StockCode(code: "035420", name: "NAVER"))
        self.tableData.append(StockCode(code: "035720", name: "카카오"))
        self.tableData.append(StockCode(code: "005380", name: "현대차"))
    }
    
    
    func stockPost(){
        guard let serverURL: URL = URL(string: "http://15.164.214.228:8000/getDf") else {return}
        var request = URLRequest(url: serverURL)
        let decoder = JSONDecoder()
        
        let param : [String: String] = ["code" : "005930"]
        
//        serverURL.appendPathComponent("getDf")
    
        do{
            // cachePolicy 때문에 만히 삽질함.
            // cachePolicy 주의!!
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: [.withoutEscapingSlashes, .prettyPrinted])
        }catch (let err){
            print(err.localizedDescription)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                print(error?.localizedDescription)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                return
            }
            
            do{
                let stockData = try decoder.decode(StockData.self, from: data)
                let yVal = (0..<stockData.openPrice.count).map { (i) -> CandleChartDataEntry in
                    let openPrice = stockData.openPrice[i]
                    let closePrice = stockData.closePrice[i]
                    let lowPrice = stockData.lowPrice[i]
                    let highPrice = stockData.highPrice[i]
                    // MARK: 정상적인 candlestick chart
                    return CandleChartDataEntry(x: Double(i), shadowH: highPrice, shadowL: lowPrice, open: openPrice, close: closePrice)
                }
                
                DispatchQueue.main.sync {
                    let set = CandleChartDataSet(entries: yVal)
                    set.shadowColor = .white
                    set.shadowWidth = 0.7
                    set.increasingColor = .red
                    set.increasingFilled = true
                    set.decreasingColor = .green
                    set.decreasingFilled = true
                    set.neutralColor = .blue
                    set.drawValuesEnabled = true
                    let data = CandleChartData(dataSet: set)
                    self.candleStickChartView.data = data
                    self.candleStickChartView.legend.enabled = true
                }
            }catch (let err){
                print(err)
            }
        }
        task.resume()
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
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = self.stockCodeTableView.dequeueReusableCell(withIdentifier: "StockCode", for: indexPath) as? StockTableViewCell else{return UITableViewCell()}
        cell.nameLabel.text = self.tableData[indexPath.item].companyName
        cell.codeLabel.text = self.tableData[indexPath.item].companyCode
        return cell
    }
    
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}

extension ViewController : ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        print(highlight)
    }
    
}
