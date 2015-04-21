//
//  EditEventViewController.swift
//  Roomguru
//
//  Created by Radoslaw Szeja on 13/04/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation


class EditEventViewController: UIViewController {
    
    weak var aView: GroupedBaseTableView?
    
    init(viewModel: EditEventViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel?.delegate = self
        self.title = self.viewModel?.title
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        aView = loadViewWithClass(GroupedBaseTableView.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarButtons()
        setupTableView()
    }
    
    // MARK: Private
    
    private var viewModel: EditEventViewModel?
}

extension EditEventViewController: ModelUpdatable {
    
    func didChangeItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        self.view.endEditing(true)
        aView?.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
    }
        
    func addedItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        aView?.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func removedItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        aView?.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

// MARK: UITableViewDataSource

extension EditEventViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel?.sectionsCount() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?[section]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let item = viewModel?[indexPath.section]?[indexPath.row] {
            let cell = tableView.cellForItemCategory(item.category)
            
            if let item = item as? TextItem {
                return configureTextFieldCell(cell as! TextFieldCell, forItem: item)
            } else if let item = item as? SwitchItem {
                return configureSwitchCell(cell as! SwitchCell, forItem: item)
            } else if let item = item as? DateItem {
                return configureDateCell(cell as! DateCell, forItem: item)
            } else if let item = item as? LongTextItem {
                return configureTextViewCell(cell as! TextViewCell, forItem: item)
            } else if let item = item as? DatePickerItem {
                return configureDatePickerCell(cell as! DatePickerCell, forItem: item)
            } else if let item = item as? ActionItem {
                return configureRightDetailTextCell(cell as! RightDetailTextCell, forItem: item)
            }
        }
        
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate

extension EditEventViewController: UITableViewDelegate {
        
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowIfSelectedAnimated(true)
        viewModel?.handleDateItemSelectionAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let item = viewModel?[indexPath.section]?[indexPath.row] {
            if let item = item as? DatePickerItem, cell = cell as? DatePickerCell {
                item.bindDatePicker(cell.datePicker)
            } else if let item = item as? SwitchItem, cell = cell as? SwitchCell {
                item.bindSwitchControl(cell.switchControl)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let item = viewModel?[indexPath.section]?[indexPath.row] {
            if let item = item as? DatePickerItem, cell = cell as? DatePickerCell {
                item.unbindDatePicker(cell.datePicker)
            } else if let item = item as? SwitchItem, cell = cell as? SwitchCell {
                item.unbindSwitchControl(cell.switchControl)
            }
        }
    }
}

// MARK: Actions

extension EditEventViewController {
    
    func didTapSaveBarButton(sender: UIBarButtonItem) {
        view.endEditing(true)
        viewModel?.saveEvent({ response in
            self.dismissSelf(self.viewModel)
        }, failure: { error in
            // NGRTemp:
            println(error)
        })
    }
    
    func didTapDismissBarButton(sender: UIBarButtonItem) {
        dismissSelf(sender)
    }
}

// MARK: Cell configuration

private extension EditEventViewController {
    
    func configureTextFieldCell(cell: TextFieldCell, forItem item: TextItem) -> UITableViewCell {
        cell.textField.delegate = item
        cell.textField.placeholder = item.placeholder
        cell.textField.text = item.title
        cell.selectionStyle = .None
        return cell
    }
    
    func configureSwitchCell(cell: SwitchCell, forItem item: SwitchItem) -> UITableViewCell {
        item.bindSwitchControl(cell.switchControl)
        cell.textLabel?.text = item.title
        cell.selectionStyle = .None
        return cell
    }
    
    func configureDateCell(cell: DateCell, forItem item: DateItem) -> UITableViewCell {
        cell.textLabel?.text = item.title
        cell.dateLabel.text = item.dateString
        cell.setSelectedLabelColor(item.selected)
        return cell
    }
    
    func configureTextViewCell(cell: TextViewCell, forItem item: LongTextItem) -> UITableViewCell {
        cell.textView.attributedText = item.attributedPlaceholder
        cell.textView.delegate = item
        return cell
    }
    
    func configureDatePickerCell(cell: DatePickerCell, forItem item: DatePickerItem) -> UITableViewCell {
        cell.datePicker.setDate(item.date, animated: false)
        cell.selectionStyle = .None
        return cell
    }
    
    func configureRightDetailTextCell(cell: RightDetailTextCell, forItem item: ActionItem) -> UITableViewCell {
        cell.textLabel?.text = item.title
        cell.detailLabel.text = item.detailDescription
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
}

// MARK: Private

private extension EditEventViewController {
    
    // MARK: Configuration
    
    func setupTableView() {
        let tableView = aView?.tableView
        
        tableView?.estimatedRowHeight = 44.0
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        tableView?.registerClass(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier())
        tableView?.registerClass(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseIdentifier())
        tableView?.registerClass(DateCell.self, forCellReuseIdentifier: DateCell.reuseIdentifier())
        tableView?.registerClass(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier())
        tableView?.registerClass(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.reuseIdentifier())
        tableView?.registerClass(RightDetailTextCell.self, forCellReuseIdentifier: RightDetailTextCell.reuseIdentifier())
    }
    
    func setupBarButtons() {
        let dismissSelector = Selector("didTapDismissBarButton:")
        let saveSelector = Selector("didTapSaveBarButton:")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: saveSelector)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: dismissSelector)
    }
}

private extension UITableView {

    func cellForItemCategory(category: GroupItem.Category) -> UITableViewCell? {
        var reuseIdentifier = ""
        
        switch category {
        case .PlainText: reuseIdentifier = TextFieldCell.reuseIdentifier()
        case .Boolean: reuseIdentifier = SwitchCell.reuseIdentifier()
        case .Date: reuseIdentifier = DateCell.reuseIdentifier()
        case .LongText: reuseIdentifier = TextViewCell.reuseIdentifier()
        case .Picker: reuseIdentifier = DatePickerCell.reuseIdentifier()
        case .Action: reuseIdentifier = RightDetailTextCell.reuseIdentifier()
        default: reuseIdentifier = ""
        }
        
        return dequeueReusableCellWithIdentifier(reuseIdentifier) as? UITableViewCell
    }
}

