//
//  HomeViewController.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import UIKit
import MapKit

class EBHomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        baseViewModel = EBHomeViewModel()
        navigationItem.title = "地震预警列表"
        addTableView()
    }
    
    private func addTableView() {
        self.blt_addTableView(with: .refresh)
        self.blt_tableView.blt.registerReusableCell(cell: EBHomeListCell.self)
        self.blt_tableView.separatorStyle = .singleLine
        self.blt_tableView.separatorColor = .blt.ccBackgroundColor()
        self.blt_tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.blt_beginRefresh()
    }
    
    /// 跳转到地图详情页面
    private func pushPositionMapController(_ model: EBHomeFeatureModel){
        let vc = EBEarthPositionMapDetailController.init()
        vc.lon = model.geometry.coordinates[0]
        vc.lat = model.geometry.coordinates[1]
        vc.defaultTitle = model.properties.place
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension EBHomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseViewModel.dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.blt.dequeueReusableCell(EBHomeListCell.self, indexPath: indexPath)
        if let model = baseViewModel.dataSources[indexPath.row] as? EBHomeFeatureModel{
            cell.model = model
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = baseViewModel.dataSources[indexPath.row] as? EBHomeFeatureModel else{
            return
        }
        pushPositionMapController(model)
    }
    
}
