//
//  ExtraInfoTableViewCell.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/28.
//

import UIKit
import SnapKit

class ExtraInfoTableViewCell: UITableViewCell {
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

    var value: String? {
        didSet {
            self.valueLabel.text = value
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
