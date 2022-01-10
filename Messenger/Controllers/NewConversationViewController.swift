//
//  NewConversationViewController.swift
//  Messanger
//
//  Created by 송경진 on 2022/01/06.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    
    private let searchBar: UISearchBar = {
        let searchBar  = UISearchBar()
        
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
        forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancle",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dissmissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
    }
    

}

extension NewConversationViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
