//
//  home_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel?
    var tableView: UITableView?
    
    init(viewModel: HomeViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.tableView = UITableView()
        self.viewModel = viewModel
        self.viewModel?.onModelReady = onModelUpdate(homeViewModel:)
        self.viewModel?.onModelUpdate = onModelUpdate(homeViewModel:)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints({ make in
            make.leading.top.trailing.bottom.equalToSuperview()
        })
    }
    
    func onModelUpdate(homeViewModel: HomeViewModel) {
        tableView?.reloadData()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.reports.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        if let model = viewModel?.reports[indexPath.row] {
            var content = cell.defaultContentConfiguration()
            content.text = "\(model.waterbody) @ \(model.station)"
            content.secondaryText = "flow: \(model.speed) m^3/s, depth: \(model.depth) cm"
            cell.contentConfiguration = content
        }
        return cell
    }
}
