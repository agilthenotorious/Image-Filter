//
//  ViewController.swift
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
        }
    }
    
    var providers = [(provider: Provider, isOn: Bool)]()
    var imageDict = [String: [UIImage]]()
    
    let links: [String] = ["http://www.splashbase.co/api/v1/images/search?query=laptop"]
    var urls: [String] = []
    var filteredList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProviders()
        getDataFromServer()
    }
    
    func setupProviders() {
        let splash = Provider(name: "Splash", url: "http://www.splashbase.co/api/v1/images/search?", parameters: ["query": ""], header: nil)
        self.providers.append((provider: splash, isOn: true))
        /*
        let pexels = Provider(name: "Pexels", url: "https://api.pexels.com/v1/search?",
         parameters: ["query"], header: ["Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"])
        
        self.providers = [(provider: splash, isOn: true),
                         (provider: pexels, isOn: true)]
        */
    }
    
    func getDataFromServer() {
        let group = DispatchGroup()
        
        for index in 0..<links.count {
            guard let link = URL(string: links[index]) else { continue }
            group.enter()
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: link)
                    let responseObj = try JSONDecoder().decode(ApiResponse.self, from: data)
                    
                    if let imageInfo = responseObj.images, let url = imageInfo.url {
                        do {
                            self.urls.append(self.links[index])
                            guard let url = URL(string: url) else { return }
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                if let image = UIImage(data: data) {
                                    self.imageArray.append(image)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                    group.leave()
                } catch {
                    print(error)
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
            self.tableView.tableFooterView = UIView()
        }
    }
}

extension ImagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ImagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageDict.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesTableViewCell.identifier, for: indexPath) as? ImagesTableViewCell else { fatalError("Unable to dequeue cell") }
        
        cell.cellImageView.image = imageDict[indexPath.row]
        return cell
    }
}

extension FilterViewController: ProviderDelegate {
    func updateProviders(provider: Provider, isOn: Bool) {
        <#code#>
    }
}

extension ImagesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        searchBar.text              = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //*
        if !searchText.isEmpty {
            
            var newList: [String] = []
            for link in self.links {
                if link.uppercased().contains(searchText.uppercased()) {
                    newList.append(link)
                }
            }
            self.filteredList = newList
        } else {
            self.filteredList = self.links
        }
        self.tableView.reloadData()
        //*/
    }
}
