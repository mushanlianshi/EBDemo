//
//  HomeViewModel.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import UIKit
import BLTSwiftUIKit

class EBHomeViewModel: ZGBaseViewModel {
    
    var resultModel: EBHomeResultModel?

    override init() {
        super.init()
        listRequest = EBHomeListRequest.lb_init()
    }
    
    override func blt_swiftListModel(fromResponse response: [AnyHashable : Any]!) -> [Any]! {
        guard let dic = response as? [String : Any] else { return [Any]() }
        resultModel = EBHomeResultModel.deserialize(from: dic)
        return resultModel?.features ?? [Any]()
    }
    
}

