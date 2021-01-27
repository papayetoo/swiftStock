//
//  AddStockViewCell.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/27.
//

import UIKit
import SnapKit

class AddStockViewCell: UITableViewCell {
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var name: String? {
        didSet{
            guard let name = self.name else {return}
            self.nameLabel.text = name
        }
    }
    
    private let codeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var code: String? {
        didSet{
            guard let code = self.code else{return}
            self.codeLabel.text = code
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setLayout(){
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints{
            $0.centerY.equalTo(self.contentView)
            $0.leading.equalTo(self.contentView).offset(10)
            $0.width.equalTo(150)
        }
        self.contentView.addSubview(self.codeLabel)
        self.codeLabel.snp.makeConstraints{
            $0.centerY.equalTo(self.contentView)
            $0.trailing.equalTo(self.contentView).offset(-10)
            $0.width.equalTo(150)
        }
    }

}
