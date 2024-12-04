//
//  LBBaseView.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import UIKit

public class LBBaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        
    }
}
