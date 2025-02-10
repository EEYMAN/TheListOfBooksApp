
import UIKit
import RxSwift
import RxCocoa
import SnapKit

/// ViewController for displaying the list of books.
class MainViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let viewModel: MainViewModel
    private var isSelectingItems = false

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView() // Set up the table view
        bindTableView()  // Bind the table view with data
        restoreSelectButton() // Restore the select button state
    }

    /// Setup table view with constraints and appearance.
    private func setupTableView() {
        view.addSubview(tableView)

        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.separatorStyle = .none

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }

    /// Bind the viewModel data to the table view and handle item selection.
    private func bindTableView() {
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: BookTableViewCell.identifier, cellType: BookTableViewCell.self)) { _, item, cell in
                cell.configure(with: item)
                cell.isUserInteractionEnabled = self.isSelectingItems
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(ItemModel.self)
            .subscribe(onNext: { [weak self] item in
                if self?.isSelectingItems == true {
                    self?.toggleItemSelection(item)
                    self?.updateNextButtonVisibility()
                }
            })
            .disposed(by: disposeBag)

        viewModel.items
            .subscribe(onNext: { [weak self] items in
                self?.navigationItem.rightBarButtonItem?.isEnabled = !items.isEmpty
            })
            .disposed(by: disposeBag)
    }

    /// Update the visibility of the "Next" button.
    private func updateNextButtonVisibility() {
        let hasSelectedItems = viewModel.items.value.contains { $0.isSelected }
        navigationItem.rightBarButtonItem = hasSelectedItems ? UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped)) : nil
    }

    /// Toggle item selection and update button state.
    @objc private func selectButtonTapped() {
        isSelectingItems.toggle()

        if isSelectingItems {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSelection))
            cancelButton.setTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = nil
        }

        updateItemsSelection()
    }

    /// Update the selection state of all items in the list.
    private func updateItemsSelection() {
        var allItems = viewModel.items.value
        for i in 0..<allItems.count {
            allItems[i].isSelected = isSelectingItems ? allItems[i].isSelected : false
        }
        viewModel.items.accept(allItems)
        tableView.reloadData()
        updateNextButtonVisibility()
    }

    /// Toggle the selection state of a specific item.
    private func toggleItemSelection(_ item: ItemModel) {
        var allItems = viewModel.items.value
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems[index].isSelected.toggle()
        }
        viewModel.items.accept(allItems)

        if let indexPath = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPath) as? BookTableViewCell {
                cell.updateSelectionState(isSelected: allItems[indexPath.row].isSelected)
            }
        }

        updateNextButtonVisibility()
    }

    /// Handle the action when the "Next" button is tapped.
    @objc private func nextButtonTapped() {
        let alert = UIAlertController(title: "Add to Favorites", message: "Add selected to Favorites?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.addSelectedItemsToFavorites()
            self?.resetButtonStatesAndSelections()
            self?.showSuccessAlert()
        })
        yesAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        alert.addAction(yesAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    /// Show success alert when items are added to favorites.
    private func showSuccessAlert() {
        let successAlert = UIAlertController(title: "Done!", message: "Added to Favorites", preferredStyle: .alert)
        present(successAlert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            successAlert.dismiss(animated: true)
        }
    }

    /// Add selected items to the favorites list.
    private func addSelectedItemsToFavorites() {
        let selectedItems = viewModel.items.value.filter { $0.isSelected }
        selectedItems.forEach { item in
            viewModel.addToFavorites(item: item)
        }

        var currentItems = viewModel.items.value
        currentItems.removeAll { $0.isSelected }
        viewModel.items.accept(currentItems)
        resetItemSelection()
    }

    /// Reset button states and selections.
    private func resetButtonStatesAndSelections() {
        isSelectingItems = false
        navigationItem.leftBarButtonItem = nil
        resetItemSelection()
        restoreSelectButton()
    }

    /// Reset the selection state for all items.
    private func resetItemSelection() {
        var allItems = viewModel.items.value
        for i in 0..<allItems.count {
            allItems[i].isSelected = false
        }
        viewModel.items.accept(allItems)
    }

    /// Cancel selection and reset the button states.
    @objc private func cancelSelection() {
        isSelectingItems = false
        restoreSelectButton()
        navigationItem.leftBarButtonItem = nil
        resetItemSelection()
    }

    /// Restore the "Select" button when no items are selected.
    private func restoreSelectButton() {
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectButtonTapped))
        selectButton.isEnabled = !viewModel.items.value.isEmpty
        navigationItem.rightBarButtonItem = selectButton
    }
}
