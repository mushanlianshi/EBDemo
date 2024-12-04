//
//  HomeListRequest.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import UIKit

/// 地震列表接口
class EBHomeListRequest: LBBaseRequest {
    
    override func requestUrlPath() -> String {
        "/fdsnws/event/1/query?format=geojson&starttime=2023-01-01&endtime=2024-01-01&minmagnitude=7"
    }
    
    override func requestMethodType() -> LBRequestMethodType {
        .GET
    }
}
