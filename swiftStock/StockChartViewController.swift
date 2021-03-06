//
//  StockChartViewController.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/11.
//

import UIKit
import Charts
import SnapKit
import CoreData

class StockChartViewController: UIViewController {

    private let serverURL = URL(string: "http://3.34.192.214:8000")
    private var stockData: StockData? {
        didSet {
            guard let stockData = self.stockData else {return}
            let closePrice = stockData.closePrice
            let volume = stockData.volume
            DispatchQueue.main.async {
                self.closePrices = (0..<closePrice.count).map {
                    return ChartDataEntry(x: Double($0), y: closePrice[$0])
                }
                self.volumes = (0..<volume.count).map {
                    return BarChartDataEntry(x: Double($0), y: Double(volume[$0]))
                }
                self.extraInfoTableView.reloadData()
            }
        }
    }
    var stockCode: StockCode? {
        didSet {
            print("stockCode new Value set")
            print(stockCode?.companyCode, stockCode?.companyName)
            self.setChart()
        }
    }
    // MARK: StackView 설정
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .top
        return stackView
    }()
    // MARK: StackView 내에서 선택한 종목 관련 정보 표시 위한 영역
    private let infoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // MARK: StackView 내에서 chart 그리기 위한 영역
    private let chartContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // MARK: buttonContainerView
    private let buttonContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .white
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    let cellIdentifier = "extraInfo"
    // MARK: extraInfoTableView
    private let extraInfoTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()

    private let extraInfoElements: [String] = ["전일 종가", "시가", "고가", "저가", "종가", "거래량"]

    private let dateRangeButtons: [UIButton] = {
        let dateRange: [String] = ["5D", "2W", "1M", "3M", "6M", "1Y"]
        let buttons: [UIButton] =  (0..<dateRange.count).map {
            let button =  UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
            button.setTitle(dateRange[$0], for: .normal)
            button.setTitleColor(.systemGray2, for: .normal)
            return button
        }
        return buttons
    }()

    // MARK: 회사명 표시 라벨
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // UI 테스트용
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    // MARK: 회사명 저장하는 변수(옵셔널 타입)
    var companyName: String? {
        didSet {
            guard let companyName = self.companyName else {return}
            self.companyNameLabel.text = companyName
        }
    }
    // MARK: 코스피 또는 코스닥
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "KOSPI"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()

    private let starButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.translatesAutoresizingMaskIntoConstraints = false
        guard let image = UIImage(named: "bstar_filled") else {return button}
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()

    private var term: Int = 5 {
        didSet {
            self.setChart()
        }
    }

    // MARK: 현재 시세 표시 라벨
    private let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "80000원"
        label.textColor = .black
        return label
    }()
    // MARK: 현재 시세 저장 변수
    var currentPrice: Double? {
        didSet {
            guard let currentPrice = self.currentPrice else {return}
            self.currentPriceLabel.text = String(format: "%d", Int(currentPrice))
        }
    }
    private var closePrices: [ChartDataEntry]? {
        didSet {
            let lineChartDataSet = LineChartDataSet(entries: self.closePrices)
            lineChartDataSet.drawValuesEnabled = false
            lineChartDataSet.lineWidth = 2.5
            // 원표시 설정
            lineChartDataSet.drawCirclesEnabled = false
            // 원표시에 구멍 그릴지 말지 설정.
            lineChartDataSet.drawCircleHoleEnabled = false
            // 영역 아래 그라디언트 세팅.
            lineChartDataSet.drawFilledEnabled = true
            // 둥근 선 그리기 위한 옵션
            lineChartDataSet.mode = .cubicBezier
            // LineChartView 줄 색 선택
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            self.closePriceLineChartView.data = lineChartData
        }
    }

    private var volumes: [BarChartDataEntry]? {
        didSet {
            let barChartDataSet = BarChartDataSet(entries: self.volumes)
            let barChartData = BarChartData(dataSet: barChartDataSet)
            self.voulmeChartView.data = barChartData
        }
    }

    // MARK: CharView 영역 테스트
    private lazy var closePriceLineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.isUserInteractionEnabled = false
        chartView.minOffset = 0
        chartView.xAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.autoScaleMinMaxEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        chartView.legend.enabled = false
        return chartView
    }()
    // MARK: BarChatView
    private lazy var voulmeChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .white
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.isUserInteractionEnabled = false
        chartView.minOffset = 0
        chartView.xAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        chartView.legend.enabled = false
        return chartView
    }()

    // MARK: CandleStickChartView 그리기 위함.
    private lazy var candleStickChartView: CandleStickChartView = {
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
        if let font = UIFont(name: "Helevetica-Nueue", size: 10) {
            chartView.legend.font = font
        }
        chartView.backgroundColor = .white
        chartView.drawGridBackgroundEnabled = false
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: candlestickChartView 테스트 코드
        self.setStackView()
        self.setInfoView()
        self.setChartView()
        self.setButtonContainerView()
        self.setExtraInfoTableView()
    }

    func setStackView() {
        self.view.addSubview(self.stackView)
        self.stackView.backgroundColor = .white
        self.stackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    // MARK: 선택된 종목의 (요약)정보를 보여주기 위한 영역의 constraints 설정
    func setInfoView() {
        self.stackView.addSubview(self.infoContainerView)
        self.infoContainerView.backgroundColor = .white
        // 회사명 표시 라벨
        self.infoContainerView.addSubview(self.companyNameLabel)
        // 현재 가격 표시 라벨
        self.infoContainerView.addSubview(self.categoryLabel)
        self.infoContainerView.addSubview(self.starButton)
        // stackView 와 infoView 사이에서 contraints 설정.
        self.infoContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.stackView)
            $0.bottom.equalTo(self.stackView.snp.top).offset(70)
        }
        // 회사명 표시 라벨 contraints 설정
        self.companyNameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.infoContainerView.snp.leading).offset(10)
            $0.bottom.equalTo(self.infoContainerView.snp.centerY).offset(-3)
        }
        // 코스닥 구분 라벨 contraints 설정
        self.categoryLabel.snp.makeConstraints {
            $0.top.equalTo(self.infoContainerView.snp.centerY).offset(3)
            $0.leading.equalTo(self.infoContainerView.snp.leading).offset(10)
        }
        // 별표시 버튼 추가
        self.starButton.snp.makeConstraints {
            $0.centerY.equalTo(self.infoContainerView.snp.centerY)
            $0.trailing.equalTo(self.infoContainerView.snp.trailing).offset(-5)
        }
        self.starButton.addTarget(self, action: #selector(self.touchUpStarButton(_:)), for: .touchUpInside)
    }
    // MARK: ChartView 영역의 constraints 설정
    func setChartView() {
        self.stackView.addSubview(self.chartContainerView)
        self.chartContainerView.backgroundColor = .white
        self.chartContainerView.snp.makeConstraints {
            $0.top.equalTo(self.infoContainerView.snp.bottom)
            $0.leading.trailing.equalTo(self.stackView)
            $0.bottom.equalTo(self.infoContainerView.snp.bottom).offset(220)
        }
        self.chartContainerView.addSubview(self.closePriceLineChartView)
        self.closePriceLineChartView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.chartContainerView)
            $0.bottom.equalTo(self.chartContainerView.snp.top).offset(180)
        }
        self.chartContainerView.addSubview(self.voulmeChartView)
        self.voulmeChartView.snp.makeConstraints {
            $0.top.equalTo(self.closePriceLineChartView.snp.bottom)
            $0.bottom.leading.trailing.equalTo(self.chartContainerView)
        }
    }

    // MARK: setButtonContainerView
    func setButtonContainerView() {
        self.stackView.addSubview(self.buttonContainerView)
        self.stackView.spacing = 5
        self.buttonContainerView.snp.makeConstraints {
            $0.leading.equalTo(self.stackView).offset(20)
            $0.trailing.equalTo(self.stackView).offset(-20)
            $0.top.equalTo(self.chartContainerView.snp.bottom)
            $0.height.equalTo(70)
        }

        _ = self.dateRangeButtons.map {
            self.buttonContainerView.addArrangedSubview($0)
            $0.addTarget(self, action: #selector(self.touchUpRangeButton(_:)), for: .touchUpInside)
        }

        self.dateRangeButtons[0].isSelected = true
        self.dateRangeButtons[0].setTitleColor(.systemBlue, for: .normal)

    }
    // MARK: setExtraInfoView()
    func setExtraInfoTableView() {
        self.stackView.addSubview(self.extraInfoTableView)
        self.extraInfoTableView.register(ExtraInfoTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.extraInfoTableView.dataSource = self
        self.extraInfoTableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.stackView)
            $0.top.equalTo(self.buttonContainerView.snp.bottom)
        }
    }

    // MARK: 별 버튼 눌렀을 때 star_fill 과 star_empty로 변경하기 위한 함수
    // TODO: CoreData에 별표 눌렀을 시 즐겨찾기 기능 추가해야함.
    @objc func touchUpStarButton(_ button: UIButton) {

        var isStarFilled: Bool?
        if self.starButton.currentImage == UIImage(named: "bstar_empty") {
            isStarFilled = true
            self.starButton.setImage(UIImage(named: "bstar_filled"), for: .normal)
        } else if self.starButton.currentImage == UIImage(named: "bstar_filled") {
            isStarFilled = false
            self.starButton.setImage(UIImage(named: "bstar_empty"), for: .normal)
        }
        // Core Data 즐겨찾기 업데이트 위한 코드
        let context = PersistenceManager.shared.context
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StockInfo")
        guard let code = self.stockCode?.companyCode else {return}
        request.predicate = NSPredicate(format: "code == %@", code)
        do {
            guard let objects = try context.fetch(request) as? [StockInfo] else {return}
            _ = objects.map {
                $0.setValue(isStarFilled, forKey: "star")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        print("update star end")

    }

    // MARK: 기간 버튼 터치시 컬러 변경
    @objc func touchUpRangeButton(_ button: UIButton) {
        if button.isSelected {return}
        let dateRangeValue: [String: Int] = ["5D": 5, "2W": 14, "1M": 30, "3M": 90, "6M": 180, "1Y": 365]

        _ = self.dateRangeButtons.map {
            if $0 == button {
                guard let title = $0.title(for: .normal), let dateRange = dateRangeValue[title] else {return}
                self.term = dateRange
                $0.isSelected = true
                $0.setTitleColor(.systemBlue, for: .normal)
            }
            if $0 != button && $0.isSelected {
                $0.isSelected = false
                $0.setTitleColor(.systemGray2, for: .normal)
            }
        }

    }

    func setLineChartData() {
        let lineChartDataEntries = (0..<20).map {
            return ChartDataEntry(x: Double($0), y: Double.random(in: 0.0...100.0))
        }
        let dataSet = LineChartDataSet(entries: lineChartDataEntries)
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 2.5
        // 원표시 설정
        dataSet.drawCirclesEnabled = false
        // 원표시에 구멍 그릴지 말지 설정.
        dataSet.drawCircleHoleEnabled = false
        // 영역 아래 그라디언트 세팅.
        dataSet.drawFilledEnabled = true
        // 둥근 선 그리기 위한 옵션
        dataSet.mode = .cubicBezier
        // LineChartView 줄 색 선택
        let lineChartData = LineChartData(dataSet: dataSet)
        self.closePriceLineChartView.data = lineChartData
    }

    func setChart() {
        DispatchQueue.global().async {
            // 서버에 request 보낸 후에 response을 받아 처리
            // complete Handler로 response을 정상적으로 받았다면
            // closePrice와 volume 데이터를 이용해 그래프 그림.
            guard let url = self.serverURL?.appendingPathComponent("getDf"), let code = self.stockCode?.companyCode else {return}
            RequestSender.shared.send(url: url, httpMethod: .post, data: FlaskRequest(code: code, term: self.term)) { (data) -> Void in
                guard let stockData = try? JSONDecoder().decode(StockData.self, from: data) else {return}
                self.stockData = stockData

            }
        }
    }
}

extension StockChartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.extraInfoElements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.extraInfoTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? ExtraInfoTableViewCell else {return UITableViewCell()}
        cell.element = self.extraInfoElements[indexPath.row]
        // ["전일 종가", "시가", "고가", "저가", "종가", "거래량"]
        guard let stockData = self.stockData else {return UITableViewCell()}
        if indexPath.row == 0 {
            cell.value = stockData.closePrice[stockData.closePrice.endIndex - 2]
        } else if indexPath.row == 1 {
            cell.value = stockData.closePrice[stockData.closePrice.endIndex - 1]
        } else if indexPath.row == 2 {
            cell.value = stockData.highPrice[stockData.highPrice.endIndex - 1]
        } else if indexPath.row == 3 {
            cell.value = stockData.lowPrice[stockData.lowPrice.endIndex - 1]
        } else if indexPath.row == 4 {
            cell.value = stockData.closePrice[stockData.closePrice.endIndex - 1]
        } else if indexPath.row == 5 {
            cell.value = Double(stockData.volume[stockData.volume.endIndex - 1])
        }

        return cell
    }
}
