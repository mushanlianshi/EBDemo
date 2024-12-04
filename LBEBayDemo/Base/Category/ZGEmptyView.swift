//
//  ZGEmptyView.swift
//  camera
//
//  Created by liu bin on 2024/5/14.
//

import Foundation
import UIKit
import BLTSwiftUIKit


@objc enum ZGEmptyViewType: Int {
    case noData = 0
    case error
}


public class ZGEmptyView: LBBaseView{
    
    private lazy var stackView: UIStackView = UIStackView.blt_stackView(withSpacing: 10, distribution: .fill, alignment: .center, axis: .vertical)!
    
    
    private lazy var imageIV = UIImageView.init(image: nil)
    
    @objc lazy var contentLab = UILabel.blt.initWithText(text: "数据加载失败，请点击重试", font: .blt.normalFont(14), textColor: .blt.hexColor(0x0E8AFD), textAlignment: .center, numberOfLines: 0)
    
    private lazy var retryBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "点击重试", font: .blt.normalFont(14), color: .white, target: self, action: #selector(retryButtonClicked), image: nil)
        button.blt.addGradientLayer(.blt.hexColor(0x31D5FF), .blt.hexColor(0x0974FF), .leftToRight, autoLayout: true)
        button.blt_layerCornerRaduis = 13
        button.isHidden = true
        button.contentEdgeInsets = .init(top: 15, left: 70, bottom: 15, right: 70)
        return button
    }()
    
    @objc var emptyType: ZGEmptyViewType = .noData{
        didSet{
            if emptyType == .noData {
                retryBtn.isHidden = true
                contentLab.text = "页面空，暂无数据"
                imageIV.image = nil
            }else{
                contentLab.text = "数据加载失败，请点击重试"
                retryBtn.isHidden = false
                imageIV.image = nil
            }
        }
    }
    
    var offsetCenterY: CGFloat = 0{
        didSet{
            stackView.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(offsetCenterY)
            }
        }
    }
    
    @objc var retryBlock: (() -> Void)?
    
    override func initSubviews() {
        addSubview(stackView)
        [imageIV, contentLab, retryBtn].forEach(stackView.addArrangedSubview(_:))
        stackView.setCustomSpacing(70, after: contentLab)
        setConstraints()
    }
    
    private func setConstraints(){
        stackView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.bottom.equalToSuperview()
        }
    }
    
    
    @objc private func retryButtonClicked() {
        retryBlock?()
    }

    
}
