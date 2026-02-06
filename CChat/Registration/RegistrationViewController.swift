import UIKit

final class RegistrationViewController: UIViewController {
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 16
        v.alignment = .fill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("welcome_title", comment: "")
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("welcome_subtitle", comment: "")
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let phoneField: UITextField = {
        let f = UITextField()
        f.placeholder = NSLocalizedString("phone_placeholder", comment: "")
        f.keyboardType = .phonePad
        f.borderStyle = .roundedRect
        f.autocapitalizationType = .none
        return f
    }()

    private let codeField: UITextField = {
        let f = UITextField()
        f.placeholder = NSLocalizedString("code_placeholder", comment: "")
        f.keyboardType = .numberPad
        f.borderStyle = .roundedRect
        f.isHidden = true
        return f
    }()

    private let nameField: UITextField = {
        let f = UITextField()
        f.placeholder = NSLocalizedString("display_name_placeholder", comment: "")
        f.borderStyle = .roundedRect
        f.autocapitalizationType = .words
        f.isHidden = true
        return f
    }()

    private let continueButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(NSLocalizedString("continue", comment: ""), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        return b
    }()

    private var step = 1
    private var phoneNumber: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(phoneField)
        stackView.addArrangedSubview(codeField)
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(continueButton)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc private func continueTapped() {
        switch step {
        case 1:
            guard let phone = phoneField.text, !phone.isEmpty else { return }
            phoneNumber = phone
            codeField.isHidden = false
            titleLabel.text = NSLocalizedString("verify_code_title", comment: "")
            subtitleLabel.text = NSLocalizedString("verify_code_subtitle", comment: "")
            phoneField.isHidden = true
            step = 2
        case 2:
            codeField.isHidden = true
            nameField.isHidden = false
            titleLabel.text = NSLocalizedString("profile_title", comment: "")
            subtitleLabel.text = NSLocalizedString("profile_subtitle", comment: "")
            step = 3
        case 3:
            let name = nameField.text ?? phoneNumber
            do {
                try AccountService.shared.register(phoneNumber: phoneNumber, displayName: name)
                showMainApp()
            } catch {
                showAlert(message: NSLocalizedString("error_registration", comment: ""))
            }
        default:
            break
        }
    }

    private func showMainApp() {
        let nav = UINavigationController(rootViewController: ConversationListViewController())
        nav.navigationBar.prefersLargeTitles = true
        guard let window = view.window else { return }
        window.rootViewController = nav
    }

    private func showAlert(message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
        present(ac, animated: true)
    }
}
