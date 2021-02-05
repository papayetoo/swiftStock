//
//  ExtraInfoTableViewCell.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/28.
//

import UIKit
import SnapKit

class ExtraInfoTableViewCell: UITableViewCell {
    // MARK: 숫자 형식 세자리마다 , 찍어줌
    private let numberFormatter: NumberFormatter =  {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        return formatter
    }()

    var element: String? {
        didSet {
            self.elementLabel.text = element
        }
    }

    private let elementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var value: Double? {
        didSet {
            guard let newValue = value else {return}
            self.valueLabel.text = self.numberFormatter.string(for: newValue)
        }
    }

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setLayout() {
        self.contentView.addSubview(self.elementLabel)
        self.contentView.addSubview(self.valueLabel)
        self.elementLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView)
            $0.leading.equalTo(self.contentView).offset(10)
        }
        self.valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView)
            $0.trailing.equalTo(self.contentView).offset(-10)
        }
    }
}
