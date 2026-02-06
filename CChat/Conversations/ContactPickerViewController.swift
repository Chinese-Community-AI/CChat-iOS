import UIKit

final class ContactPickerViewController: UIViewController {
    var onSelect: ((Contact) -> Void)?

    private var contacts: [Contact] = []
    private var isAddingNew = false

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("new_chat", comment: "")
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("add_contact", comment: ""),
            style: .plain,
            target: self,
            action: #selector(addContact)
        )
        setupTable()
        loadContacts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isAddingNew { loadContacts() }
        isAddingNew = false
    }

    private func setupTable() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    private func loadContacts() {
        do {
            contacts = try MessageService.shared.getContacts()
            tableView.reloadData()
        } catch {}
    }

    @objc private func cancel() {
        dismiss(animated: true)
    }

    @objc private func addContact() {
        let ac = UIAlertController(
            title: NSLocalizedString("add_contact", comment: ""),
            message: NSLocalizedString("add_contact_message", comment: ""),
            preferredStyle: .alert
        )
        ac.addTextField { $0.placeholder = NSLocalizedString("phone_placeholder", comment: "") }
        ac.addTextField { $0.placeholder = NSLocalizedString("display_name_placeholder", comment: "") }
        ac.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        ac.addAction(UIAlertAction(title: NSLocalizedString("add", comment: ""), style: .default) { [weak self] _ in
            guard let self = self,
                  let phone = ac.textFields?[0].text, !phone.isEmpty else { return }
            let name = ac.textFields?[1].text
            do {
                _ = try MessageService.shared.addContact(phoneNumber: phone, displayName: name)
                self.isAddingNew = true
                self.loadContacts()
            } catch {}
        })
        present(ac, animated: true)
    }
}

extension ContactPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let c = contacts[indexPath.row]
        cell.textLabel?.text = c.displayName ?? c.phoneNumber
        cell.detailTextLabel?.text = c.phoneNumber
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect?(contacts[indexPath.row])
        dismiss(animated: true)
    }
}
