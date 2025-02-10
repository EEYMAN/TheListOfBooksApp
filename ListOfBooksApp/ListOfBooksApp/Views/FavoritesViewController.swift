
import UIKit
import RxSwift
import RxCocoa
import SnapKit

/// ViewController for displaying favorite books.
class FavoritesViewController: UIViewController {
    
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
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
        setupTableView()
        setupBindings()
        restoreSelectButton()
    }

    /// Sets up table view with constraints.
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

    /// Binds data to the table view and handles selection.
    private func setupBindings() {
        viewModel.favoriteItems
            .subscribe(onNext: { [weak self] _ in
                self?.updateSelectButtonState()
            })
            .disposed(by: disposeBag)

        viewModel.favoriteItems
            .bind(to: tableView.rx.items(cellIdentifier: BookTableViewCell.identifier, cellType: BookTableViewCell.self)) { _, item, cell in
                cell.configure(with: item)
                cell.updateSelectionState(isSelected: item.isSelected)
                cell.isUserInteractionEnabled = self.isSelectingItems
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(ItemModel.self)
            .subscribe(onNext: { [weak self] item in
                if self?.isSelectingItems == true {
                    self?.toggleItemSelection(item)
                    self?.updateDeleteButtonVisibility()
                }
            })
            .disposed(by: disposeBag)
    }

    /// Updates the state of the select button based on the item list.
    private func updateSelectButtonState() {
        let hasItems = !viewModel.favoriteItems.value.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = hasItems
    }

    /// Handles select/cancel actions.
    @objc private func selectButtonTapped() {
        isSelectingItems.toggle()

        if isSelectingItems {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSelection))
            navigationItem.rightBarButtonItem = nil
        }

        updateItemsSelection()
    }

    /// Updates the selection state of all items.
    private func updateItemsSelection() {
        var allItems = viewModel.favoriteItems.value
        for i in 0..<allItems.count {
            allItems[i].isSelected = isSelectingItems ? allItems[i].isSelected : false
        }
        viewModel.favoriteItems.accept(allItems)
        tableView.reloadData()
        updateDeleteButtonVisibility()
    }

    /// Toggles the selection state of an item.
    private func toggleItemSelection(_ item: ItemModel) {
        var allItems = viewModel.favoriteItems.value
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems[index].isSelected.toggle()
        }
        viewModel.favoriteItems.accept(allItems)
        tableView.reloadData()
        updateDeleteButtonVisibility()
    }

    /// Presents a confirmation alert to delete selected items.
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "Remove", message: "Delete selected items?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.removeSelectedItemsFromFavorites()
            self?.resetButtonStatesAndSelections()
            self?.showRemovalSuccessAlert()
        }))

        present(alert, animated: true)
    }

    /// Shows a success alert after items are deleted.
    private func showRemovalSuccessAlert() {
        let successAlert = UIAlertController(title: "Deleted", message: "Removed from Favorites", preferredStyle: .alert)
        present(successAlert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            successAlert.dismiss(animated: true)
        }
    }

    /// Removes selected items from favorites.
    private func removeSelectedItemsFromFavorites() {
        let selectedItems = viewModel.favoriteItems.value.filter { $0.isSelected }
        selectedItems.forEach { item in
            viewModel.removeFromFavorites(item: item)
        }
        let updatedFavorites = viewModel.favoriteItems.value.filter { !$0.isSelected }
        viewModel.favoriteItems.accept(updatedFavorites)

        resetItemSelection()
        updateDeleteButtonVisibility()
        updateSelectButtonState()
    }

    /// Updates the visibility of the delete button.
    private func updateDeleteButtonVisibility() {
        let hasSelectedItems = viewModel.favoriteItems.value.contains { $0.isSelected }
        if hasSelectedItems {
            let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
            deleteButton.setTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
            navigationItem.rightBarButtonItem = deleteButton
        } else {
            restoreSelectButton()
        }
    }

    /// Resets button states and item selections.
    private func resetButtonStatesAndSelections() {
        isSelectingItems = false
        navigationItem.leftBarButtonItem = nil
        resetItemSelection()
        updateDeleteButtonVisibility()
        updateSelectButtonState()
    }

    /// Resets the selection state for all items.
    private func resetItemSelection() {
        var allItems = viewModel.favoriteItems.value
        for i in 0..<allItems.count {
            allItems[i].isSelected = false
        }
        viewModel.favoriteItems.accept(allItems)
        tableView.reloadData()
        updateDeleteButtonVisibility()
    }

    /// Cancels the selection mode and resets buttons.
    @objc private func cancelSelection() {
        isSelectingItems = false
        restoreSelectButton()
        navigationItem.leftBarButtonItem = nil
        resetItemSelection()
        updateDeleteButtonVisibility()
        updateSelectButtonState()
    }

    /// Restores the "Select" button when no items are selected.
    private func restoreSelectButton() {
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectButtonTapped))
        selectButton.isEnabled = !viewModel.favoriteItems.value.isEmpty
        navigationItem.rightBarButtonItem = selectButton
    }
}
