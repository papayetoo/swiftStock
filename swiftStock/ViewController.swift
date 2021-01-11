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
    
    // MARK: CandleStickChartView 연습
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
//        chartView.legend.font = UIFont(name: "HeleveticaNeue-Light", size: 10)!
        chartView.backgroundColor = .black
        
        chartView.drawGridBackgroundEnabled = false
        return chartView
    }()
    
    var candleData : [CandleChartDataEntry] = []
    
    let session: URLSession = URLSession(configuration: .default)
    
    let yValues : [ChartDataEntry] = [
        ChartDataEntry(x:1.0, y:2.0),
        ChartDataEntry(x:2.0, y:4.0),
        ChartDataEntry(x:3.0, y:6.0),
        ChartDataEntry(x:4.0, y:8.0),
        ChartDataEntry(x:5.0, y:10.0),
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.view.addSubview(self.candleStickChartView)
        self.candleStickChartView.snp.makeConstraints({
            $0.leading.trailing.equalTo(self.view).offset(0)
            $0.top.equalTo(self.view).offset(0)
            $0.bottom.equalTo(self.view).offset(0)
        })
        
        self.candleStickChartView.delegate = self
        self.stockPost()
//        self.setCandleChartData()
//        self.setDataCount(10, range: 7)
    }
    
    
    
    func stockPost(){
        
        guard let serverURL: URL = URL(string: "http://15.164.214.228:8000/getDf") else {return}
        var request = URLRequest(url: serverURL)
        let decoder = JSONDecoder()
        
        let param : [String: String] = ["code" : "005930"]
        
//        serverURL.appendPathComponent("getDf")
    
        
        do{
            // cachePolicy 때문에 만히 삽질함.
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
    
    func setData(){
        let setOne = LineChartDataSet(entries: yValues, label: "Test")
        
        let data = LineChartData(dataSet: setOne)
        lineChartsView.data = data
    }
    
}


extension ViewController : ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        print(highlight)
    }
    
}
