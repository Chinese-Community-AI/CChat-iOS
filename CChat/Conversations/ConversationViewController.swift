import UIKit

final class ConversationViewController: UIViewController {
    private let conversation: Conversation
    private let contact: Contact

    private var messages: [Message] = []

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.register(MessageCell.self, forCellReuseIdentifier: MessageCell.id)
        t.separatorStyle = .none
        t.backgroundColor = .systemGroupedBackground
        return t
    }()

    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        return v
    }()

    private let inputField: UITextField = {
        let f = UITextField()
        f.placeholder = NSLocalizedString("message_placeholder", comment: "")
        f.borderStyle = .roundedRect
        f.returnKeyType = .send
        return f
    }()

    private let sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return b
    }()

    init(conversation: Conversation, contact: Contact) {
        self.conversation = conversation
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = contact.displayName ?? contact.phoneNumber
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        loadMessages()
        inputField.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(sendButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safe.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),

            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 56),

            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func loadMessages() {
        do {
            messages = try MessageService.shared.getMessages(for: conversation.id)
            tableView.reloadData()
            scrollToBottom(animated: false)
        } catch {}
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let last = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: last, at: .bottom, animated: animated)
    }

    @objc private func sendTapped() {
        sendMessage()
    }

    private func sendMessage() {
        guard let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        inputField.text = nil
        do {
            _ = try MessageService.shared.sendMessage(to: conversation.id, body: text)
            loadMessages()
        } catch {
            let ac = UIAlertController(title: nil, message: NSLocalizedString("error_send", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
            present(ac, animated: true)
        }
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.id, for: indexPath) as! MessageCell
        cell.configure(body: msg.body, date: msg.createdAt, isOutgoing: msg.isOutgoing)
        return cell
    }
}

extension ConversationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
