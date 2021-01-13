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
    
    var codeLabel : UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var closePriceChartView : LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.xAxis.drawGridLinesEnabled = false
        return chartView
    }()
    
    var chartDataEntry : [ChartDataEntry]? {
        didSet {
            print("chartDataEntrySet", self.chartDataEntry)
            DispatchQueue.main.async {
                let dataSet = LineChartDataSet(entries: self.chartDataEntry)
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
        print(self.closePriceChartView.data)
    }
    
    func setLayout() {
        self.contentView.addSubview(self.nameLabel)
//        self.contentView.addSubview(self.codeLabel)
        self.contentView.addSubview(self.closePriceChartView)
        
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
        }
        
//        self.codeLabel.snp.makeConstraints {
//            $0.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(10)
//            $0.trailing.equalTo(self.contentView.safeAreaLayoutGuide).offset(-10)
//        }
        
        self.closePriceChartView.snp.makeConstraints{
            $0.top.bottom.trailing.equalTo(self.contentView.safeAreaLayoutGuide).offset(0)
            $0.leading.equalTo(self.nameLabel.snp.trailing).offset(5)
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
