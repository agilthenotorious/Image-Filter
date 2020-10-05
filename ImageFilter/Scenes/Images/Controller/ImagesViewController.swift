//
//  ImagesViewController.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/2/20.
//

import UIKit

class ImagesViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet { self.searchBar.delegate = self }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var providers = [(provider: Provider, isOn: Bool)]()
    var imageDict = [String: [ImageInfo]]()
    var sections = [String]()
    var dataSource = [ImageInfo]()
    
    @IBAction func filter(_ sender: UIBarButtonItem) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Images"
        setupProviders()
        setupUI()
    }
    
    func setupUI() {
        self.tableView.isHidden = true
        self.activityIndicator.startAnimating()
        setupKeyboardHandlers()
    }
    
    func setupProviders() {
        let splash = Provider(name: "Splash", url: "http://www.splashbase.co/api/v1/images/search?", parameters: ["query"], header: nil)
        self.providers.append((provider: splash, isOn: true))
        
        let pexels = Provider(name: "Pexels", url: "https://api.pexels.com/v1/search?", parameters: ["query"], header: ["Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"])
        
        self.providers = [(provider: splash, isOn: true),
                         (provider: pexels, isOn: true)]
        
    }
    
    func setupKeyboardHandlers() {
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
    }
    
    func getDataFromServer(about keyword: String) {
        //let group = DispatchGroup()
        self.title = keyword.uppercased()
        for providerInstance in providers where providerInstance.isOn == true {
            let urlString = providerInstance.provider.url + providerInstance.provider.parameters[0] + "=" + keyword
            guard let link = URL(string: urlString) else { continue }
            //group.enter()
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: link)
                    let responseObj = try JSONDecoder().decode(ApiResponse.self, from: data)
                    if let imageInfo = responseObj.images {
                        self.dataSource.append(contentsOf: imageInfo)
                    }
                    //group.leave()
                } catch {
                    print(error)
                    //group.leave()
                }
            }
        }
        //group.notify(queue: DispatchQueue.main) {
        self.tableView.isHidden = false
        self.activityIndicator.stopAnimating()
        self.tableView.reloadData()
        //}
        
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filterVC = segue.destination as? FilterViewController else { return }
            
        filterVC.delegate = self
        filterVC.providerInfoArray = self.providers
    }
}

extension ImagesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.sections.removeAll()
        for providerInstance in self.providers where providerInstance.isOn == true {
            self.sections.append(providerInstance.provider.name)
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesTableViewCell.identifier, for: indexPath) as? ImagesTableViewCell else { fatalError("Unable to dequeue cell") }
        
        let item = self.dataSource[indexPath.row]
        cell.configureCell(using: item)
        return cell
    }
}

extension ImagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ImagesViewController: ProviderDelegate {
    func updateProviders(provider: Provider, isOn: Bool) {
        for (index, providerItem) in self.providers.enumerated() where providerItem.provider.name == provider.name {
            self.providers[index].isOn = isOn
            self.tableView.reloadData()
        }
    }
}

extension ImagesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count >= 5 else {
            self.title = "Images"
            return
        }
        
        self.getDataFromServer(about: searchText)
    }
}
