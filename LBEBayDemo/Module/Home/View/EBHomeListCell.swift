//
//  HomeListCell.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import UIKit
import BLTSwiftUIKit
import BLTUIKitProject

class EBHomeListCell: UITableViewCell {
    
    private lazy var stackView = UIStackView.blt_stackView(withSpacing: 6, distribution: .fill, alignment: .leading, axis: .vertical)!
    
    private lazy var titleLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(17), textColor: .blt.threeThreeBlackColor(), numberOfLines: 0)
    
    private lazy var horiStackView = UIStackView.blt_stackView(withSpacing: 3, distribution: .fill, alignment: .fill, axis: .horizontal)!
    
    private lazy var magTagLab: BLTContentInsetLabel = {
       let label = BLTContentInsetLabel.blt.initWithText(text: "", font: .blt.normalFont(11), textColor: .white)
        label.backgroundColor = .blt.ffRedColor()
        label.contentEdgeInsets = .init(top: 0, left: 3, bottom: 0, right: 3)
        label.blt_layerCornerRaduis = 2
        return label
    }()
    
    private lazy var cdiTagLab: BLTContentInsetLabel = {
       let label = BLTContentInsetLabel.blt.initWithText(text: "", font: .blt.normalFont(11), textColor: .white)
        label.backgroundColor = .blue
        label.contentEdgeInsets = .init(top: 0, left: 3, bottom: 0, right: 3)
        label.blt_layerCornerRaduis = 2
        return label
    }()
    
    
    
    var model: EBHomeFeatureModel?{
        didSet{
            guard let properties = model?.properties else { return }
            titleLab.text = properties.title
            magTagLab.text = properties.magDes
            cdiTagLab.text = properties.cdiDes
            if properties.mag > 7.5 {
                titleLab.textColor = .blt.ffRedColor()
                magTagLab.backgroundColor = .blt.ffRedColor()
            }else{
                titleLab.textColor = .blt.threeThreeBlackColor()
                magTagLab.backgroundColor = .green
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [titleLab, horiStackView].forEach(stackView.addArrangedSubview(_:))
        [magTagLab, cdiTagLab].forEach(horiStackView.addArrangedSubview(_:))
        contentView.addSubview(stackView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints(){
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        }
        
    }
    
    
}
