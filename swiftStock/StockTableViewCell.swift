//
//  StockTableViewCell.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/11.
//

import UIKit

class StockTableViewCell: UITableViewCell {
    
    var codeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
