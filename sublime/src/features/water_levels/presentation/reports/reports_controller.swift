//
//  reports_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import cleanboot_swift

class ReportsController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    typealias OnSelect = (IndexPath, WaterLevelReport) -> Void
    
    var viewModel: ReportsViewModel
    var onSelect: OnSelect?
    var toggleFavorite: ToggleFavoriteStationUseCase?
    var getFavoriteStatus: GetFavoriteStatusUseCase?
    
    init(
        viewModel: ReportsViewModel,
        onSelect: OnSelect? = nil,
        toggleFavorite: ToggleFavoriteStationUseCase
    ) {
        self.viewModel = viewModel
        self.onSelect = onSelect
        self.toggleFavorite = toggleFavorite
    }
    
    func setReports(_ reports: [WaterLevelReport]) {
        self.viewModel.reports = reports
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reportCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "reportCell",
            for: indexPath
        )
        
        let viewModel = viewModel.reportCellViewModels[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.text()
        content.secondaryText = viewModel.secondaryText()
        cell.accessoryView?.removeFromSuperview()
        let button = buildFavoriteButton(viewModel: viewModel)
        button.addAction(UIAction(
            handler: { action in
                Task.init {
                    await self.updateFavorite(
                        tableView: tableView,
                        indexPath: indexPath
                    )
                }
            }), for: .touchUpInside)
        cell.accessoryView = button
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onSelect = onSelect {
            onSelect(indexPath, viewModel.reports[indexPath.row])
        }
    }
    
    @objc
    func updateFavorite(tableView: UITableView, indexPath: IndexPath) async {
        do {
            let vm = viewModel.reportCellViewModels[indexPath.row]
            let code = vm.report.stationCode
            let response = try await toggleFavorite?.execute(params: code)
            switch response {
            case .success(let favorited):
                vm.favorite = favorited
            default:
                debugPrint("not favorited")
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } catch {
            debugPrint(error)
        }
    }
    
    @objc func beginRefresh() async {
        await viewModel.prepareData()
    }
    
    func filter(text: String) {
        viewModel.filter(text: text)
    }
}

extension ReportsController {
    func buildFavoriteButton(viewModel: ReportCellViewModel) -> UIButton {
        let button = UIButton()
        button.sizeToFit()
        button.setImage(viewModel.favoriteImage(), for: .normal)
        button.tintColor = viewModel.favorite ? .systemYellow : .systemGray
        button.isSelected = viewModel.favorite
        return button
    }
}
