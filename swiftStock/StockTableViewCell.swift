//
//  StockTableViewCell.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/11.
//

import UIKit
import Charts
import SnapKit


class StockTableViewCell: UITableViewCell {
    
    // MARK: 코드명칭 UILabel
    var codeLabel : UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: 회사명칭 UILabel
    var nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: 마지막날 가격 및 전날 대비 증가율%
    var currentPrice : Double? {
        didSet{
            guard let price = self.currentPrice else{return}
            self.currentPriceLabel.text = String(format: "%d", Int(price))
        }
    }
    var currentPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var percent: Double? {
        didSet{
            guard let percent = self.percent else{return}
            self.percentLabel.text = String(format: "(%.2f%%)", percent)
        }
    }
    
    var percentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: 종가 LineChartView
    var closePriceChartView : LineChartView = {
        let chartView = LineChartView()
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
    
    var containerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.4
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: 전날과 비교 상승/하락 판단
    var isIncreasing: Bool = false
    // MARK: LineChartView 그리는 데 필요한 데이터
    var chartDataEntry : [ChartDataEntry]? {
        didSet {
//            print("chartDataEntrySet", self.chartDataEntry)
            DispatchQueue.main.async {
                let dataSet = LineChartDataSet(entries: self.chartDataEntry)
                // 원표시 설정
                dataSet.drawCirclesEnabled = false
                // 원표시에 구멍 그릴지 말지 설정.
                dataSet.drawCircleHoleEnabled = false
                // 영역 아래 그라디언트 세팅.
                dataSet.drawFilledEnabled = true
                // 둥근 선 그리기 위한 옵션
                dataSet.mode = .cubicBezier
                // LineChartView 줄 색 선택
                dataSet.setColor(self.isIncreasing ? UIColor(red: 255, green: 0, blue: 0) : UIColor(red: 0, green: 255, blue: 0))
                let colorTop = self.isIncreasing ? UIColor.systemRed.cgColor : UIColor.systemGreen.cgColor
                let colorBottom = UIColor.white.cgColor
                let gradientColors = [colorTop, colorBottom] as CFArray
                let colorLocations: [CGFloat] = [1.0, 0.0]
                guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) else{return}
                dataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
                let data = LineChartData(dataSet: dataSet)
                self.closePriceChartView.data = data
            }
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        self.contentView.addSubview(self.nameLabel)
//        self.contentView.addSubview(self.codeLabel)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }
    
    // MARK: setLayOut -> 서브뷰 추가 및 레이아웃 설정
    func setLayout() {
        self.contentView.addSubview(self.containerView)
        self.containerView.addSubview(self.nameLabel)
        self.containerView.addSubview(self.closePriceChartView)
        self.containerView.addSubview(self.currentPriceLabel)
        self.containerView.addSubview(self.percentLabel)
        // containerView Contraints 설정
        self.containerView.snp.makeConstraints{
            $0.leading.equalTo(self.contentView).offset(10)
            $0.trailing.equalTo(self.contentView).offset(-10)
            $0.top.bottom.equalTo(self.contentView)
        }
        // nameLabel Contraints 설정
        self.nameLabel.snp.makeConstraints{
            $0.leading.equalTo(self.containerView).offset(10)
            $0.top.equalTo(self.containerView).offset(10)
        }
        // MARK: currentPriceLabel 설정
        self.currentPriceLabel.snp.makeConstraints{
            $0.leading.equalTo(self.containerView).offset(10)
            $0.top.equalTo(self.nameLabel.snp.bottom).offset(10)
        }
        // MARK: percentLabel 설정
        self.percentLabel.snp.makeConstraints{
            $0.leading.equalTo(self.containerView).offset(10)
            $0.top.equalTo(self.currentPriceLabel.snp.bottom).offset(10)
        }
        // closePriceChartView Contraints 설정.
        self.closePriceChartView.snp.makeConstraints{
            $0.top.bottom.trailing.equalTo(self.containerView)
            $0.leading.equalTo(self.containerView).offset(100)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
