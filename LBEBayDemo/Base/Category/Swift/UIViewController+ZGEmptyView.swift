//
//  UIViewController+ZGEmptyView.swift
//  camera
//
//  Created by liu bin on 2024/5/14.
//

import Foundation
import UIKit

public extension UIViewController{
    private struct AssociatedKeys {
            static var emptyViewKey = "zg_emptyView"
        }

    @objc var zg_emptyView: ZGEmptyView? {
            get {
                var view = objc_getAssociatedObject(self, &AssociatedKeys.emptyViewKey) as? ZGEmptyView
                if view == nil{
                    view = ZGEmptyView.init()
                }
                objc_setAssociatedObject(self, &AssociatedKeys.emptyViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return view
            }
            set {
                objc_setAssociatedObject(self, &AssociatedKeys.emptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    
    @objc func zg_showEmptyView(_ superView: UIView? = nil, emptyText: String? = nil) {
        let superView = superView ?? self.view
        guard let superView = superView, let emptyView = self.zg_emptyView else { return }
        
        superView.addSubview(emptyView)
        superView.sendSubviewToBack(emptyView)
        emptyView.isHidden = false
        emptyView.emptyType = .noData
        if let text = emptyText{
            emptyView.contentLab.text = text
        }
        emptyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func zg_showErrorView(_ superView: UIView? = nil, retryBlock: (() -> Void)?, errorMsg: String = "数据加载失败，请点击重试") {
        let superView = superView ?? self.view
        guard let superView = superView, let emptyView = self.zg_emptyView else { return }
        
        superView.addSubview(emptyView)
        superView.sendSubviewToBack(emptyView)
        emptyView.isHidden = false
        emptyView.emptyType = .error
        emptyView.contentLab.text = errorMsg
        emptyView.retryBlock = retryBlock
        emptyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func zg_hiddenEmptyOrErrorView(){
        self.zg_emptyView?.isHidden = true
    }
    
    
}
