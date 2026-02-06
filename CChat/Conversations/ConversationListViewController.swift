import UIKit

final class ConversationListViewController: UIViewController {
    private var conversations: [Conversation] = []
    private var contacts: [Contact] = []

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.id)
        t.rowHeight = 72
        return t
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("no_conversations", comment: "")
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 17)
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("chats", comment: "")
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(newChat)
        )
        setupTable()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func setupTable() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func loadData() {
        do {
            conversations = try MessageService.shared.getConversations()
            contacts = try MessageService.shared.getContacts()
            tableView.reloadData()
            emptyLabel.isHidden = !conversations.isEmpty
        } catch {
            emptyLabel.isHidden = false
        }
    }

    @objc private func newChat() {
        let vc = ContactPickerViewController()
        vc.onSelect = { [weak self] contact in
            self?.openConversation(with: contact)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    private func openConversation(with contact: Contact) {
        do {
            let conv = try MessageService.shared.getOrCreateConversation(with: contact)
            let vc = ConversationViewController(conversation: conv, contact: contact)
            navigationController?.pushViewController(vc, animated: true)
        } catch {
            let ac = UIAlertController(title: nil, message: NSLocalizedString("error_load", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
            present(ac, animated: true)
        }
    }

    private func contactForConversation(_ conv: Conversation) -> Contact? {
        let myId = AccountService.shared.currentUser?.id
        let otherId = conv.participantIds.first { $0 != myId }
        return contacts.first { $0.id == otherId || $0.userId == otherId }
            ?? contacts.first { conv.id.contains($0.id) }
    }
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.id, for: indexPath) as! ConversationCell
        let conv = conversations[indexPath.row]
        let contact = contactForConversation(conv)
        cell.configure(
            title: contact?.displayName ?? contact?.phoneNumber ?? NSLocalizedString("unknown", comment: ""),
            preview: conv.lastMessagePreview ?? "",
            date: conv.lastMessageAt
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conv = conversations[indexPath.row]
        if let contact = contactForConversation(conv) {
            openConversation(with: contact)
        }
    }
}
