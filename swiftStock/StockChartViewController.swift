//
//  StockChartViewController.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/11.
//

import UIKit
import Charts
import SnapKit

class StockChartViewController: UIViewController {
    var stockCode : StockCode?
    
    let session = URLSession.shared
    private let serverURL = URL(string: "http://3.36.72.105:8000")
    
    // MARK: CandleStickChartView 그리기 위함.
    private lazy var candleStickChartView : CandleStickChartView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: candlestickChartView 테스트 코드
        self.view.addSubview(self.candleStickChartView)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.candleStickChartView.snp.makeConstraints({
            $0.leading.trailing.equalTo(self.view).offset(0)
            $0.top.equalTo(self.view).offset(0)
            $0.bottom.equalTo(self.view).offset(0)
        })
        self.getChartData()
    }
    
    func getChartData(){
        guard let subURL = serverURL?.appendingPathComponent("getDf"), let code = stockCode?.companyCode else {return}
        var request = URLRequest(url: subURL)
        do{
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Mobile/iPhone", forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
//        request.httpBody = try JSONSerialization.data(withJSONObject: param, options: [.withoutEscapingSlashes, .prettyPrinted])
            request.httpBody = try JSONEncoder().encode(FlaskRequest(code: code))
        } catch (let err){
            print(err.localizedDescription)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                print(error?.localizedDescription)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {return}
            
            do{
                let stockData = try JSONDecoder().decode(StockData.self, from: data)
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
