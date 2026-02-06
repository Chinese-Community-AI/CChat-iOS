import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let rootVC: UIViewController
        if AccountService.shared.isRegistered {
            let chatsNav = UINavigationController(rootViewController: ConversationListViewController())
            chatsNav.navigationBar.prefersLargeTitles = true
            let settingsNav = UINavigationController(rootViewController: SettingsViewController())
            settingsNav.navigationBar.prefersLargeTitles = true
            let tabBar = UITabBarController()
            tabBar.viewControllers = [chatsNav, settingsNav]
            chatsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("chats", comment: ""), image: UIImage(systemName: "message.fill"), tag: 0)
            settingsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("settings", comment: ""), image: UIImage(systemName: "gear"), tag: 1)
            rootVC = tabBar
        } else {
            rootVC = RegistrationViewController()
            let nav = UINavigationController(rootViewController: rootVC)
            nav.navigationBar.prefersLargeTitles = true
            window.rootViewController = nav
            window.makeKeyAndVisible()
            return
        }
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
    }
}
