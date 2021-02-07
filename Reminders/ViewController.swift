//
//  ViewController.swift
//  Reminders
//
//  Created by MacBook on 2/7/21.
//

import UIKit

struct Reminder: Hashable {
    let text: String
    var completed: Bool
}

typealias DataSource = UICollectionViewDiffableDataSource<String, Reminder>
typealias Registration = UICollectionView.CellRegistration<UICollectionViewListCell, Reminder>

class ViewController: UIViewController, UICollectionViewDelegate {
    var collectionView: UICollectionView! = nil
    var dataSource: DataSource! = nil
    var reminders = [Reminder]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataSource = createDataSource()

        collectionView.delegate = self

        self.view.addSubview(collectionView)
        reminders.append(Reminder(text: "Hello, World!", completed: false))

        reloadReminders()
    }

    @IBAction func addReminder(_ sender: Any) {
        let alert = UIAlertController(title: "New Reminder", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Reminder"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let reminderText = alert.textFields?.first?.text else { return }
            let newReminder = Reminder(text: reminderText, completed: false)
            self.reminders.append(newReminder)
            self.reloadReminders()
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func createDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: self.collectionView, cellProvider: cellProvider)
        dataSource.reorderingHandlers.canReorderItem = { _ in true }
        return dataSource
    }

    func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, reminder: Reminder) -> UICollectionViewListCell {
        let registration = Registration(handler: configureCell)
        let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: reminder)
        return cell
    }

    func configureCell(cell: UICollectionViewListCell, indexPath: IndexPath, reminder: Reminder) {
        var content = cell.defaultContentConfiguration()
        content.text = reminder.text

        let alpha = reminder.completed ? 0.5 : 1
        content.textProperties.color = UIColor.black.withAlphaComponent(CGFloat(alpha))

        if reminder.completed {
            cell.accessories = [.checkmark()]
        }

        cell.contentConfiguration = content
    }

    func reloadReminders() {
        var snapshot = NSDiffableDataSourceSnapshot<String, Reminder>()
        snapshot.appendSections(["Main"])
        snapshot.appendItems(reminders)
        dataSource.apply(snapshot)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard var selectedReminder = dataSource.itemIdentifier(for: indexPath),
              let idx = reminders.firstIndex(of: selectedReminder) else { return }

        collectionView.deselectItem(at: indexPath, animated: true)
        selectedReminder.completed.toggle()
        reminders[idx] = selectedReminder

        reloadReminders()

    }
}

