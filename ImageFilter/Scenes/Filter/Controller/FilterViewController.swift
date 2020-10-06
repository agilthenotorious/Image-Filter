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
            self.tableView.allowsSelection = false
        }
    }
    
    var providers: [Provider]?
    weak var delegate: ProviderProtocol?
    
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

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.providers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.identifier, for: indexPath) as? FilterTableViewCell else { fatalError("Cell cannot be dequeued") }
        
        if let provider = self.providers?[indexPath.row] {
            cell.providerDelegate = self.delegate
            cell.switchDelegate = self
            cell.configureCell(provider: provider)
        }
        return cell
    }
}

extension FilterViewController: SwitchProtocol {
    func updateSwitches(provider: Provider, isOn: Bool) -> Bool {
        guard let providersArray = self.providers else { return true }
        
        var numOfSwitchesOn = 0
        providersArray.forEach { providerInstance in
            if providerInstance.isOn { numOfSwitchesOn += 1 }
        }
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
