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
        }
    }
    
    var providerInfoArray: [(provider: Provider, isOn: Bool)]?
    weak var delegate: ProviderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.providerInfoArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.identifier, for: indexPath) as? FilterTableViewCell else { fatalError("Cell cannot be dequeued") }
        
        if let provider = self.providerInfoArray?[indexPath.row] {
            cell.providerDelegate = self.delegate
            cell.switchDelegate = self
            cell.configureCell(provider: provider.provider, isOn: provider.isOn)
        }
        return cell
    }
}

extension FilterViewController: SwitchDelegate {
    func updateSwitches(provider: Provider, isOn: Bool) -> Bool {
        guard let providersArray = self.providerInfoArray else { return true }
        
        var numOfSwitchesOn = 0
        providersArray.forEach { providerInstance in
            if providerInstance.isOn { numOfSwitchesOn += 1 }
        }
        if !isOn && numOfSwitchesOn < 2 {
            self.showAlert()
            return false
        }
        for (index, providerInstance) in providersArray.enumerated() where providerInstance.provider.name == provider.name {
            self.providerInfoArray?[index].isOn = isOn
        }
        return true
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "😔", message: "Please keep at least one filter on", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
