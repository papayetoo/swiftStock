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
    // MARK: 종가 LineChartView
    var closePriceChartView : LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.isUserInteractionEnabled = false
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
    
    let containerView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
        view.layer.shadowColor = UIColor(named: "Orange")?.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.backgroundColor = UIColor(named: "Red")
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
                dataSet.drawCirclesEnabled = false
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
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.codeLabel)
        
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
        }
        
        self.codeLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
            $0.trailing.equalTo(self.contentView.safeAreaLayoutGuide).offset(-10)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }
    
    func setLayout() {
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(closePriceChartView)
        self.contentView.layer.borderWidth = 5
        self.contentView.layer.shadowOpacity = 0.7
        self.contentView.layer.shadowColor = UIColor(named: "Orange")?.cgColor
        self.contentView.layer.shadowRadius = 12
        self.contentView.layer.cornerRadius = 30
        self.contentView.layer.shadowOffset = CGSize(width: 10, height: 10)
        self.contentView.layer.masksToBounds = false
        
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
//            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(10)
//            $0.leading.equalTo(self.containerView.safeAreaLayoutGuide).offset(10)
        }
        
        self.closePriceChartView.snp.makeConstraints{
            $0.top.bottom.equalTo(self.contentView.safeAreaLayoutGuide)
            $0.leading.equalTo(self.contentView.safeAreaLayoutGuide).offset(100)
            $0.trailing.equalTo(self.contentView.safeAreaLayoutGuide).offset(-40)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
