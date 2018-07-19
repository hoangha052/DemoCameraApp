//
//  MGRedminePriorityViewController.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/27/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import UIKit
import PKHUD
import Async

class MGRedmineDetailViewController: UITableViewController {
    
    var detailType = MGRedmineDetailType.priority
    private var parentTasks = [MGRedmineTask]()
    private var filteredParentTasks = [MGRedmineTask]()
    private var assignees = [MGRedmineAssignee]()
    private var filteredAssignees = [MGRedmineAssignee]()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        self.navigationController?.navigationBar.tintColor = .black
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        switch detailType {
        case .task:
            fetchParentTasks()
            configureSearchController()
        case .priority:
            self.title = "Priority"
            self.refreshControl = nil
            self.tableView.isScrollEnabled = false
        case .assignee:
            fetchAssignees()
            configureSearchController()
        }
    }
    
    @objc func onPullToRefresh() {
        guard !isFiltering() else { return }
        switch  detailType {
        case .task:
            fetchParentTasks()
        case .assignee:
            fetchAssignees()
        default:
            break
        }
        self.refreshControl?.endRefreshing()
    }
    
    fileprivate func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search..."
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        self.refreshControl?.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
    }
    
    private func fetchParentTasks(offset: Int = 0) {
        HUD.show(.progress)
        MGRedmineAPI.fetchParentTasks(projectID: MGRedmineIssue.shared.projectID, offset: offset) { (tasks) in
            HUD.hide()
            guard let tasks = tasks else { return }
            guard tasks.count > 0 else { MGRedmineAlert.show(message: "There is no parent tasks"); return }
            if offset == 0 {
                self.parentTasks = tasks
            } else {
                self.parentTasks.append(contentsOf: tasks)
            }
            self.tableView.reloadData()
        }
    }
    
    private func fetchAssignees(offset: Int = 0) {
        HUD.show(.progress)
        MGRedmineAPI.fetchAssignees(projectID: MGRedmineIssue.shared.projectID, offset: offset) { (assignees) in
            HUD.hide()
            guard let assignees = assignees else { return }
            guard assignees.count > 0 else { MGRedmineAlert.show(message: "There is no assignees"); return }
            if offset == 0 {
                self.assignees = assignees
            } else {
                self.assignees.append(contentsOf: assignees)
            }
            self.tableView.reloadData()
        }
    }
    
    private func shouldFetch() -> Bool {
        if self.detailType == .task {
            return parentTasks.count % MGRedmineConstants.itemsPerPage == 0
        }
        return assignees.count % MGRedmineConstants.itemsPerPage == 0
    }
    
    static func show(presentingViewController: UIViewController, detailType: MGRedmineDetailType) {
        let storyboard = UIStoryboard(name: "MGRedmine", bundle: Bundle.currentBundle())
        let viewController = storyboard.instantiateViewController(withIdentifier: "MGRedmineDetailViewController") as! MGRedmineDetailViewController
        viewController.detailType = detailType
        presentingViewController.navigationController?.pushViewController(viewController, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch detailType {
        case .priority:
            return 5
        case .task:
            return isFiltering() ? filteredParentTasks.count : parentTasks.count
        case .assignee:
            return isFiltering() ? filteredAssignees.count : assignees.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch detailType {
        case .priority:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedminePriorityCell") as! MGRedminePriorityCell
            cell.configureUI(row: indexPath.row)
            return cell
        case .task:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedmineTaskCell") as! MGRedmineTaskCell
            cell.configureUI(task: isFiltering() ? filteredParentTasks[indexPath.row] : parentTasks[indexPath.row])
            return cell
        case .assignee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedmineAssigneeCell") as! MGRedmineAssigneeCell
            cell.configureUI(assignee: isFiltering() ? filteredAssignees[indexPath.row] : assignees[indexPath.row])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard shouldFetch() else { return }
        if self.detailType == .task {
            guard indexPath.row == parentTasks.count - 1 else { return }
            fetchParentTasks(offset: parentTasks.count)
            return
        }
        guard indexPath.row == assignees.count - 1 else { return }
        fetchAssignees(offset: assignees.count)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch detailType {
        case .priority:
            guard let selectedPriority = MGRedminePriority(rawValue: indexPath.row) else { return }
            MGRedmineIssue.shared.priority = selectedPriority
        case .task:
            let selectedTaskID = isFiltering() ? filteredParentTasks[indexPath.row].id : parentTasks[indexPath.row].id
            MGRedmineIssue.shared.parentTaskID = selectedTaskID == MGRedmineIssue.shared.parentTaskID ? 0 : selectedTaskID
        case .assignee:
            let selectedAssignee = isFiltering() ? filteredAssignees[indexPath.row] : assignees[indexPath.row]
            MGRedmineIssue.shared.assignee = selectedAssignee.id == MGRedmineIssue.shared.assignee.id ? MGRedmineAssignee(json: [:]) : selectedAssignee
        }
        self.tableView.reloadData()
    }
}

// UISearchResultsUpdating
extension MGRedmineDetailViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: searchController.searchBar.text ?? "")
    }
    
    fileprivate func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    fileprivate func filterContent(searchText: String) {
        if self.detailType == .task {
            filteredParentTasks = parentTasks.filter({ $0.subject.lowercased().contains(searchText.lowercased()) })
        } else {
            filteredAssignees = assignees.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
        self.tableView.reloadData()
    }
    
    fileprivate func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
}
