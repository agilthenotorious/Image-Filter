//
//  FilterViewController.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/3/20.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.tableFooterView = UIView()
        }
    }
    
    var providers: [Provider]?
    var filterTypes: [ImageFilterType] = [.original, .blackWhite, .sepia, .bloom]
    var selectedFilterType: ImageFilterType?
    var sections: [String] = ["Providers", "Filters"]
    
    weak var delegate: ProviderDelegate?
    weak var filterDelegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Filter"
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "😔", message: "Please keep at least one filter on", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension FilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == "Providers" {
            return self.providers?.count ?? 0
        } else if sections[section] == "Filters" {
            return self.filterTypes.count
        } else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        
        case sections[0]:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProviderTableViewCell.identifier,
                                                           for: indexPath) as? ProviderTableViewCell
            else { fatalError("Provider cell cannot be dequeued") }
            
            if let provider = self.providers?[indexPath.row] {
                cell.providerDelegate = self.delegate
                cell.switchDelegate = self
                cell.configureCell(provider: provider)
            }
            cell.selectionStyle = .none
            return cell
            
        case sections[1]:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageFilterTableViewCell.identifier, for: indexPath) as? ImageFilterTableViewCell
            else { fatalError("Filter cell cannot be dequeued") }
            
            cell.configureLabel(typeName: filterTypes[indexPath.row].rawValue)
            cell.selectionStyle = .default
            cell.accessoryType = .none
            
            if self.selectedFilterType != nil && self.selectedFilterType == self.filterTypes[indexPath.row] {
                cell.accessoryType = .checkmark
            }
            return cell
            
        default:
            fatalError("No cell can be deuqeued!")
        }
    }
}

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        self.selectedFilterType = self.filterTypes[indexPath.row]
        if let selectedFilter = self.selectedFilterType {
            self.filterDelegate?.updateFilters(with: selectedFilter)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
    }
}

extension FilterViewController: SwitchDelegate {
    
    func updateSwitches(provider: Provider, isOn: Bool) -> Bool {
        guard let providersArray = self.providers else { return true }
        
        let numOfSwitchesOn = providersArray.filter { $0.isOn }.count
        if !isOn && numOfSwitchesOn < 2 {
            self.showAlert()
            return false
        }
        for (index, providerInstance) in providersArray.enumerated() where providerInstance == provider {
            self.providers?[index].isOn = isOn
        }
        return true
    }
}
