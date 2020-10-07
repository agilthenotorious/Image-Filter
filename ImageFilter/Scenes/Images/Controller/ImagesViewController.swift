//
//  ImagesViewController.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/2/20.
//

import UIKit

class ImagesViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.tableFooterView = UIView()
            self.tableView.keyboardDismissMode = .onDrag
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var sectionDataSourceStored = [Sections]()
    var sectionDataSource: [Sections] {
        concurrentQueue.sync {
            return sectionDataSourceStored
        }
    }
    var selectedFilter: ImageFilterType = .original
    
    private let concurrentQueue = DispatchQueue(label: "my.concurrent.queue", attributes: .concurrent)
    private var searchWorkItem: DispatchWorkItem?
    
    @IBAction func filter(_ sender: UIBarButtonItem) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupProviders()
        self.setupUI()
    }
    
    func setupUI() {
        self.title = "Images"
        self.setupKeyboardHandlers()
        
        self.tableView.isHidden = true
        self.activityIndicator.isHidden = true
        self.warningLabel.isHidden = false
        
        self.searchBar.delegate = self
        self.tableView.reloadData()
    }
    
    func setupProviders() {
        let splash = Provider(name: "Splash", url: Splash.url, parameters: Splash.parameters, headers: nil)
        let pexels = Provider(name: "Pexels", url: Pexels.url, parameters: Pexels.parameters, headers: Pexels.headers)
        let pixabay = Provider(name: "Pixabay", url: Pixabay.url, parameters: Pixabay.parameters, headers: nil)
        
        self.sectionDataSourceStored = [Sections(provider: splash, dataSource: []),
                                        Sections(provider: pexels, dataSource: []),
                                        Sections(provider: pixabay, dataSource: [])]
    }
    
    func setupKeyboardHandlers() {
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateParameter(with text: String, _ dict: [String: String]) -> [String: String] {
        
        var parameters = dict
        
        if dict["query"] != nil {
            parameters["query"] = text
        } else if parameters["q"] != nil {
            parameters["q"] = text
        }
        return parameters
    }
    
    func updateSection(provider: Provider, dictionary: Any?) -> [ImageProtocol] {
        
        guard let dictionary = dictionary as? [String: Any] else { return [] }
        var newSection: [ImageProtocol] = []
        
        switch provider.name {
        case Splash.name:
            guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { return [] }
            arrayItems.forEach { dictionary in
                newSection.append(SplashImageInfo(dict: dictionary))
            }
            
        case Pexels.name:
            guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return [] }
            arrayItems.forEach { dictionary in
                newSection.append(PexelsImageInfo(dict: dictionary))
            }
            
        case Pixabay.name:
            guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return [] }
            arrayItems.forEach { dictionary in
                newSection.append(PixabayImageInfo(dict: dictionary))
            }
            
        default:
            break
        }
        return newSection
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filterVC = segue.destination as? FilterViewController else { return }
        
        var providers = [Provider]()
        self.sectionDataSource.forEach { section in
            providers.append(section.provider)
        }
        filterVC.providers = providers
        filterVC.selectedFilterType = self.selectedFilter
        filterVC.delegate = self
        filterVC.filterDelegate = self
        
    }
}

extension ImagesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionDataSource.filter { $0.provider.isOn }.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let displaySections = self.sectionDataSource.filter { $0.provider.isOn }
        return displaySections[section].provider.name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let displaySections = self.sectionDataSource.filter { $0.provider.isOn }
        return displaySections[section].dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesTableViewCell.identifier,
                                                       for: indexPath) as? ImagesTableViewCell
        else { fatalError("Unable to dequeue cell") }
        
        let displaySections = self.sectionDataSource.filter { $0.provider.isOn }
        let url = displaySections[indexPath.section].dataSource[indexPath.row].imageUrl ?? ""
        cell.configureCell(using: url, filter: self.selectedFilter)

        return cell
    }
}

extension ImagesViewController: ProviderProtocol {
    
    func updateProviders(provider: Provider, isOn: Bool) {
        for (index, section) in self.sectionDataSource.enumerated() where section.provider == provider {
            self.sectionDataSourceStored[index].provider.isOn = isOn
        }
        self.tableView.reloadData()
    }
}

extension ImagesViewController: FilterProtocol {
    
    func updateFilters(with filter: ImageFilterType) {
        self.selectedFilter = filter
        self.tableView.reloadData()
    }
}

extension ImagesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count < 5 { return }
        self.searchWorkItem?.cancel()

        let uiLoaderWork = DispatchWorkItem {
            self.warningLabel.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }

        self.searchWorkItem = DispatchWorkItem {
            
            DispatchQueue.main.async(execute: uiLoaderWork)
            let providerGroup = DispatchGroup()
            
            for (index, section) in self.sectionDataSource.enumerated() {
                let parameters = self.updateParameter(with: text, section.provider.parameters)
                providerGroup.enter()
                NetworkManager.shared.request(urlString: section.provider.url, headers: section.provider.headers,
                                              parameters: parameters) { [section] dictionary in
                    self.concurrentQueue.sync(flags: .barrier) {
                        self.sectionDataSourceStored[index].dataSource =
                            self.updateSection(provider: section.provider, dictionary: dictionary)
                        providerGroup.leave()
                    }
                }
            }

            providerGroup.notify(queue: DispatchQueue.main) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                if self.sectionDataSource.isEmpty {
                    self.warningLabel.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.warningLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            }
        }
        
        if let work = self.searchWorkItem {
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: work)
        }
    }
}
