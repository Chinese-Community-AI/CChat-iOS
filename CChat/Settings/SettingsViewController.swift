import UIKit

final class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("settings", comment: "")
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let profileLabel = UILabel()
        profileLabel.text = AccountService.shared.currentUser?.displayName
            ?? AccountService.shared.currentUser?.phoneNumber
            ?? ""
        profileLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        stack.addArrangedSubview(profileLabel)

        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        stack.addArrangedSubview(logoutButton)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func logoutTapped() {
        do {
            try AccountService.shared.logout()
            let nav = UINavigationController(rootViewController: RegistrationViewController())
            nav.navigationBar.prefersLargeTitles = true
            guard let window = view.window else { return }
            window.rootViewController = nav
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } catch {}
    }
}
